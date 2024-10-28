#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция СозданныеАкты(Параметры) Экспорт
	
	Результат = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Договор КАК Договор,
	|	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
	|	РеализацияТоваровУслуг.Организация Как Организация,
	|	РеализацияТоваровУслуг.Дата
	|ПОМЕСТИТЬ ВТ_СозданныеДокументы
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ПО РеализацияТоваровУслуг.Договор = ДоговорыКонтрагентов.Ссылка
	|		И РеализацияТоваровУслуг.Контрагент = ДоговорыКонтрагентов.Владелец
	|ГДЕ
	|	РеализацияТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Организация КАК Организация,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ДоговорыКонтрагентов.Ссылка КАК Договор
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СозданныеДокументы КАК ВТ_СозданныеДокументы
	|		ПО ДоговорыКонтрагентов.Ссылка = ВТ_СозданныеДокументы.Договор
	|ГДЕ
	|	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	|	И ДоговорыКонтрагентов.ВКМ_ДатаНачала <= &НачалоПериода
	|	И ДоговорыКонтрагентов.ВКМ_ДатаОкончания >= &КонецПериода
	|	И НЕ ДоговорыКонтрагентов.Ссылка В
	|		(ВЫБРАТЬ
	|			ВТ_СозданныеДокументы.Договор КАК Договор
	|		ИЗ
	|			ВТ_СозданныеДокументы КАК ВТ_СозданныеДокументы)";
	
	Запрос.УстановитьПараметр("ВидДоговора", Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоДня(Параметры.Период.ДатаНачала));
	Запрос.УстановитьПараметр("КонецПериода", КонецДня(Параметры.Период.ДатаОкончания));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НовыйДокумент = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		НовыйДокумент.Дата = Выборка.Дата;
		НовыйДокумент.Организация = Выборка.Организация;
		НовыйДокумент.Контрагент = Выборка.Контрагент;
		НовыйДокумент.Записать();
		
		НовыйДокумент.ВКМ_ВыполнитьАвтозаполнение();
		НовыйДокумент.ПроверитьЗаполнение();
		НовыйДокумент.Записать();
		
		Если Не НовыйДокумент.ПроверитьЗаполнение() Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Ошибка при записи документа";
			Сообщение.Сообщить();
			Продолжить;
		КонецЕсли;
		
		НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
		
	КонецЦикла;
		
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#КонецЕсли
