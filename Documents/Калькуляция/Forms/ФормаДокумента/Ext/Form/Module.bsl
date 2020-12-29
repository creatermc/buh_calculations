﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Объект.Исполнитель = Пользователи.АвторизованныйПользователь();  
	Объект.Валюта = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	
	// СтандартныеПодсистемы.ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	
	Если Параметры.Ключ.Пустая() Тогда
		ПодготовитьФормуНаСервере();
	КонецЕсли;
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры

// Внешний вид, содержание надписей и т.п.

&НаСервере
Процедура УстановитьУсловноеОформление()

	НастройкиУсловногоОформления = Новый Структура();

	УсловноеОформление.Элементы.Очистить();

	// Условное оформление, связанное с видимостью, устанавливаем сразу для всех колонок.
	УстановитьУсловноеОформлениеВидимость();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПодготовитьФормуНаСервере()

	ТекущаяДатаДокумента			= Объект.Дата;

	ВалютаРегламентированногоУчета 	= Константы.ВалютаРегламентированногоУчета.Получить();
	
	УстановитьФункциональныеОпцииФормы();
	
	Если Объект.СчетДоходов.Пустая() Тогда
		СчетДоходовКоличествоСубконто = 0;
	Иначе
		СвойстваСчета = БухгалтерскийУчетВызовСервераПовтИсп.ПолучитьСвойстваСчета(Объект.СчетДоходов);
		СчетДоходовКоличествоСубконто = СвойстваСчета.КоличествоСубконто;
	КонецЕсли;

	Если ИспользоватьОднуНоменклатурнуюГруппу Тогда
		НоменклатурнаяГруппаВознаграждения = БухгалтерскийУчетВызовСервераПовтИсп.ОсновнаяНоменклатурнаяГруппа();
	ИначеЕсли ЗначениеЗаполнено(Объект.УслугаПоВознаграждению) Тогда
		НоменклатурнаяГруппаВознаграждения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
			Объект.УслугаПоВознаграждению, "НоменклатурнаяГруппа");
	КонецЕсли;
	
	БухгалтерскийУчетКлиентСервер.УстановитьНачальныеСвойстваСубконтоШапки(
		ЭтотОбъект, Объект, ПараметрыУстановкиСвойствСубконто(ЭтотОбъект));
	
	СписокСпособовРасчета = ОбщегоНазначенияБПКлиентСервер.СформироватьСписокСпособовРасчетаКомиссионногоВознаграждения(Истина);
	СписокВыбора = Элементы.СпособРасчетаКомиссионногоВознаграждения.СписокВыбора;
	СписокВыбора.Очистить();
	Для Каждого ЭлементСписка Из СписокСпособовРасчета Цикл
		СписокВыбора.Добавить(ЭлементСписка.Значение, ЭлементСписка.Представление);
	КонецЦикла;
	
	Элементы.СтавкаНДСВознаграждения.СписокВыбора.Очистить();
	Для Каждого СтавкаНДС Из Перечисления.СтавкиНДС Цикл
		Элементы.СтавкаНДСВознаграждения.СписокВыбора.Добавить(СтавкаНДС);
	КонецЦикла;

	УстановитьЗаголовкиКолонок();
	
	Документы.ОтчетКомитентуОПродажах.УстановитьЗаголовокФормы(ЭтаФорма);
	
	// Устанавливаем видимость, доступность и заголовоки прочих элементов:
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФункциональныеОпцииФормы()

	ОбщегоНазначенияБПКлиентСервер.УстановитьПараметрыФункциональныхОпцийФормыДокумента(ЭтаФорма);
	
	ИспользоватьТипыЦенНоменклатуры	     = ПолучитьФункциональнуюОпцию("ИспользоватьТипыЦенНоменклатуры");
	ЕстьВалютныйУчет 				     = БухгалтерскийУчетПереопределяемый.ИспользоватьВалютныйУчет();
	ИспользоватьОднуНоменклатурнуюГруппу = БухгалтерскийУчетВызовСервераПовтИсп.ИспользоватьОднуНоменклатурнуюГруппу();

КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформлениеВидимость()

	// ТоварыВсего

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыВсего");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.СуммаВключаетНДС", ВидСравненияКомпоновкиДанных.Равно, Истина);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);


	// ТоварыВсегоВознаграждение

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыВсегоВознаграждение");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.СуммаВключаетНДС", ВидСравненияКомпоновкиДанных.Равно, Истина);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);

КонецПроцедуры



&НаКлиенте
Процедура СобственныеУслугиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	УдалитьПустыеСтроки(Объект.СобственныеУслуги, Новый Структура("Номенклатура", ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка")));
	Модифицированность = Истина;

	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("Параметр", "СобственныеУслуги");
	оп = Новый ОписаниеОповещения("ПослеВыбораУслуг", ЭтаФорма, ДопПараметры);
	ОткрытьФорму("ОбщаяФорма.ФормаВыбораАктов",ДопПараметры ,Элемент ,,,,оп ,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

&НаКлиенте
Процедура УдалитьПустыеСтроки(ТаблицаУдаления, СтруктураУсловия)
	
	МассивПустыхСтрок = ТаблицаУдаления.НайтиСтроки(СтруктураУсловия); 
	Если МассивПустыхСтрок.Количество() > 0 Тогда
		Для каждого Строка Из МассивПустыхСтрок Цикл 
			ТаблицаУдаления.Удалить(Строка); 
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораУслуг(РезультатЗакрытия, ДопПараметры) Экспорт
	УдалитьПустыеСтроки(Объект.СобственныеУслуги, Новый Структура("Номенклатура", ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка")));
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораОтчетаКомитенту(РезультатЗакрытия, ДопПараметры) Экспорт
	УдалитьПустыеСтроки(Объект.АгентскиеУслуги, Новый Структура("Номенклатура", ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка")));
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура Группа1ПриСменеСтраницы(Элемент, ТекущаяСтраница)
	УдалитьПустыеСтроки(Объект.СобственныеУслуги, Новый Структура("Номенклатура", ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка")));
	Модифицированность = Истина;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОбновитьСписокУслугКалькуляции" Тогда
			Для Каждого СтрокаПараметра из Параметр Цикл
				ОтборПоНоменклатуре = Новый Структура();
				ОтборПоНоменклатуре.Вставить("Номенклатура", СтрокаПараметра.Номенклатура);
				НайденноеЗначение = Объект.СобственныеУслуги.НайтиСтроки(ОтборПоНоменклатуре); 
					Если НайденноеЗначение.Количество() > 0 Тогда
							Для Каждого СтрокаНайденноеЗначение Из НайденноеЗначение Цикл 
								СтрокаНайденноеЗначение.Сумма =  СтрокаНайденноеЗначение.Сумма + СтрокаПараметра.Сумма;
								СтрокаНайденноеЗначение.НДС = СтрокаНайденноеЗначение.НДС + СтрокаПараметра.СуммаНДС;
								СтрокаНайденноеЗначение.Всего = СтрокаНайденноеЗначение.Всего + СтрокаПараметра.Всего;
								СтрокаНайденноеЗначение.Количество = СтрокаНайденноеЗначение.Количество + СтрокаПараметра.Количество;
								СтрокаНайденноеЗначение.Цена = СтрокаНайденноеЗначение.Цена + СтрокаПараметра.Цена;
							КонецЦикла;
						Продолжить;
					КонецЕсли;
				НовСтрока = Объект.СобственныеУслуги.Добавить();
				НовСтрока.Номенклатура = СтрокаПараметра.Номенклатура;
				НовСтрока.Сумма = СтрокаПараметра.Сумма;
				НовСтрока.НДС = СтрокаПараметра.СуммаНДС;
				НовСтрока.Всего = СтрокаПараметра.Всего;
				НовСтрока.Количество = СтрокаПараметра.Количество;
				НовСтрока.Содержание = СтрокаПараметра.Содержание;
				НовСтрока.АналитикаУчета = СтрокаПараметра.АналитикаУчета;
				НовСтрока.СтавкаНДС = СтрокаПараметра.СтавкаНДС;
				НовСтрока.Субконто = СтрокаПараметра.Субконто;
				НовСтрока.СчетДоходов = СтрокаПараметра.СчетДоходов;
				НовСтрока.СчетНаОплатуПокупателю = СтрокаПараметра.СчетНаОплатуПокупателю;
				НовСтрока.СчетРасходов = СтрокаПараметра.СчетРасходов;
				НовСтрока.СчетУчетаНДСПоРеализации = СтрокаПараметра.СчетУчетаНДСПоРеализации;
				НовСтрока.Цена = СтрокаПараметра.Цена;
			КонецЦикла;
		Объект.СуммаДокумента = Объект.СуммаДокумента + Объект.СобственныеУслуги.Итог("Всего");
		ИтогСуммаНДС = ИтогСуммаНДС + Объект.СобственныеУслуги.Итог("НДС");
	КонецЕсли;

	Если ИмяСобытия = "ПолучитьСписокУслугПоОтчетуКомитента" Тогда
			Для Каждого СтрокаПараметра из Параметр Цикл
				Если СтрокаПараметра.Ключ = "ДокументОтчетаКомитента" Тогда 
								Объект.СпособРасчетаКомиссионногоВознаграждения = СтрокаПараметра.Значение[0];
								Объект.ПроцентКомиссионногоВознаграждения = СтрокаПараметра.Значение[1];
								Объект.СчетУчетаНДСПоРеализации = СтрокаПараметра.Значение[2];
								Объект.СтавкаНДСВознаграждения = СтрокаПараметра.Значение[3];
								Объект.УслугаПоВознаграждению = СтрокаПараметра.Значение[4];
									УслугаПоВознаграждениюПриИзмененииНаСервере();
								Объект.СчетДоходов = СтрокаПараметра.Значение[5];
								Объект.Субконто = СтрокаПараметра.Значение[6];
						ИначеЕсли СтрокаПараметра.Ключ = "ВыбранныеТоварыИУслуги" Тогда
							Для Каждого ТекСтрока из СтрокаПараметра.Значение Цикл
								ОтборПоНоменклатуре = Новый Структура();
								ОтборПоНоменклатуре.Вставить("Номенклатура", ТекСтрока.Номенклатура);
								НайденноеЗначение = Объект.АгентскиеУслуги.НайтиСтроки(ОтборПоНоменклатуре); 
									Если НайденноеЗначение.Количество() > 0 Тогда
											Для Каждого СтрокаНайденноеЗначение Из НайденноеЗначение Цикл 
												СтрокаНайденноеЗначение.Сумма =  СтрокаНайденноеЗначение.Сумма + ТекСтрока.Сумма;
												СтрокаНайденноеЗначение.СуммаНДС = СтрокаНайденноеЗначение.СуммаНДС + ТекСтрока.СуммаНДС;
												СтрокаНайденноеЗначение.Всего = СтрокаНайденноеЗначение.Всего + ТекСтрока.Всего;
												СтрокаНайденноеЗначение.Количество = СтрокаНайденноеЗначение.Количество + ТекСтрока.Количество;
												СтрокаНайденноеЗначение.Цена = СтрокаНайденноеЗначение.Цена + ТекСтрока.Цена;
												СтрокаНайденноеЗначение.КоличествоМест = СтрокаНайденноеЗначение.КоличествоМест + ТекСтрока.КоличествоМест;
												СтрокаНайденноеЗначение.ВсегоВознаграждение = СтрокаНайденноеЗначение.ВсегоВознаграждение + ТекСтрока.ВсегоВознаграждение;
												СтрокаНайденноеЗначение.СуммаВознаграждения = СтрокаНайденноеЗначение.СуммаВознаграждения + ТекСтрока.СуммаВознаграждения;
												СтрокаНайденноеЗначение.СуммаНДСВознаграждения = СтрокаНайденноеЗначение.СуммаНДСВознаграждения + ТекСтрока.СуммаНДСВознаграждения;
											КонецЦикла;
										Продолжить;
									КонецЕсли;
								НовСтрока = Объект.АгентскиеУслуги.Добавить();
								НовСтрока.Номенклатура = ТекСтрока.Номенклатура;
								НовСтрока.Сумма = ТекСтрока.Сумма;
								НовСтрока.СуммаНДС = ТекСтрока.СуммаНДС;
								НовСтрока.Всего = ТекСтрока.Всего;
								НовСтрока.Количество = ТекСтрока.Количество;
								НовСтрока.Содержание = ТекСтрока.Содержание;
								НовСтрока.Код = ТекСтрока.Код;
								НовСтрока.СтавкаНДС = ТекСтрока.СтавкаНДС;
								НовСтрока.СуммаНДСВознаграждения = ТекСтрока.СуммаНДСВознаграждения;
								НовСтрока.СуммаВознаграждения = ТекСтрока.СуммаВознаграждения;
								НовСтрока.Коэффициент = ТекСтрока.Коэффициент;
								НовСтрока.ЕдиницаИзмерения = ТекСтрока.ЕдиницаИзмерения;
								НовСтрока.КоличествоМест = ТекСтрока.КоличествоМест;
								НовСтрока.Цена = ТекСтрока.Цена;
								НовСтрока.Артикул = ТекСтрока.Артикул;
								НовСтрока.ВсегоВознаграждение = ТекСтрока.ВсегоВознаграждение;
							КонецЦикла;
					КонецЕсли; 
			КонецЦикла;
		Объект.СуммаДокумента = Объект.СобственныеУслуги.Итог("Всего") + Объект.АгентскиеУслуги.Итог("Всего");
		ИтогСуммаНДС = Объект.СобственныеУслуги.Итог("НДС") + Объект.АгентскиеУслуги.Итог("СуммаНДС");

			УстановитьЗаголовкиКолонок();
	КонецЕсли;

	Модифицированность = Истина;

КонецПроцедуры

&НаКлиенте
Процедура АгентскиеУслугиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)

	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("Параметр", "АгентскиеУслуги");
	оп = Новый ОписаниеОповещения("ПослеВыбораОтчетаКомитенту", ЭтаФорма, ДопПараметры);
	ОткрытьФорму("ОбщаяФорма.ФормаВыбораОтчетовКомитента",ДопПараметры ,Элемент ,,,,оп ,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

	УдалитьПустыеСтроки(Объект.СобственныеУслуги, Новый Структура("Номенклатура", ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка")));
	Модифицированность = Истина;

КонецПроцедуры

// Пересчеты реквизитов в строках табличных частей

&НаСервере
Процедура ПересчитатьВознаграждениеВТабличнойЧасти(ИмяТабличнойЧасти = "")

	Если НЕ ЗначениеЗаполнено(ИмяТабличнойЧасти) ИЛИ ИмяТабличнойЧасти = "Товары" Тогда
		Для Каждого СтрокаДокумента Из Объект.Товары Цикл
			РассчитатьВознаграждениеВСтроке(
				СтрокаДокумента.СуммаВознаграждения,
				СтрокаДокумента.СуммаНДСВознаграждения,
				СтрокаДокумента.ВсегоВознаграждение,
				СтрокаДокумента.Сумма,
				СтрокаДокумента.СуммаНДС,
				Объект.ПроцентКомиссионногоВознаграждения,
				Объект.СпособРасчетаКомиссионногоВознаграждения,
				Объект.СтавкаНДСВознаграждения,
				Объект.СуммаВключаетНДС);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура РассчитатьВознаграждениеВСтроке(
			Вознаграждение,
			НДСВознаграждения,
			ВсегоВознаграждение,
			Знач СуммаСтроки,
			Знач НДССтроки,
			Знач ПроцентВознаграждения,
			Знач СпособРасчета,
			Знач СтавкаНДСВознаграждения,
			Знач СуммаВключаетНДС)

	// Вознаграждение всегда рассчитывается от сумм с НДС и вначале всегда включает НДС
	Если СпособРасчета = ПредопределенноеЗначение("Перечисление.СпособыРасчетаКомиссионногоВознаграждения.НеРассчитывается") Тогда
		Вознаграждение = Вознаграждение + ?(СуммаВключаетНДС, 0, НДСВознаграждения);
	ИначеЕсли СпособРасчета = ПредопределенноеЗначение("Перечисление.СпособыРасчетаКомиссионногоВознаграждения.ПроцентОтСуммыПродажи") Тогда
		Вознаграждение = ПроцентВознаграждения / 100 * (СуммаСтроки + ?(СуммаВключаетНДС, 0, НДССтроки));
	Иначе
		Вознаграждение = 0;
	КонецЕсли;

	// Вознаграждение всегда рассчитывается от сумм с НДС и вначале всегда включает НДС
	// Теперь в зависимости от галочки СуммаВключаетНДС либо вычтем НДС, либо оставим
	Вознаграждение = УчетНДСКлиентСервер.ПересчитатьЦенуПриИзмененииФлаговНалогов(
		Вознаграждение,          // Цена,
		Истина,                  // ЦенаВключаетНДС, (на момент расчета всегда включает НДС)
		СуммаВключаетНДС,        // СуммаВключаетНДС,
		УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(СтавкаНДСВознаграждения)); // СтавкаНДС

	НДСВознаграждения = УчетНДСКлиентСервер.РассчитатьСуммуНДС(
		Вознаграждение,
		СуммаВключаетНДС,
		УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(СтавкаНДСВознаграждения));

	ВсегоВознаграждение = Вознаграждение + ?(СуммаВключаетНДС, 0, НДСВознаграждения);

КонецПроцедуры

&НаКлиенте
Процедура СтавкаНДСВознагражденияПриИзменении(Элемент)
	
	//СтавкаНДСВознагражденияПриИзмененииНаСервере();

КонецПроцедуры

&НаСервере
Процедура СтавкаНДСВознагражденияПриИзмененииНаСервере()
	
	СтавкаНДСВознагражденияОбработатьИзменение();
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры 

&НаСервере
Процедура СтавкаНДСВознагражденияОбработатьИзменение()

	Если Объект.СпособРасчетаКомиссионногоВознаграждения <> Перечисления.СпособыРасчетаКомиссионногоВознаграждения.НеРассчитывается Тогда
		ПересчитатьВознаграждениеВТабличнойЧасти();
	КонецЕсли;

КонецПроцедуры 

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)

	Элементы = Форма.Элементы;
	Объект   = Форма.Объект;
	
	Если НЕ (Форма.ИспользоватьОднуНоменклатурнуюГруппу И ЗначениеЗаполнено(Объект.Субконто)) Тогда
		Элементы.Субконто.Доступность = Форма.СчетДоходовКоличествоСубконто > 0;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СтавкаНДСВознагражденияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)

// НДС 20% (с 01.01.2019),
// НДС 18% (до 01.01.2019),

	Если Объект.СобственныеУслуги.Количество() > 0 Тогда 
		Для Каждого CтрокаСобственныеУслуги  Из Объект.СобственныеУслуги Цикл
			CтрокаСобственныеУслуги.СтавкаНДС = ВыбранноеЗначение;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20") Тогда
				CтрокаСобственныеУслуги.НДС = CтрокаСобственныеУслуги.Сумма / 120 * 20;
			КонецЕсли;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС18") Тогда
				CтрокаСобственныеУслуги.НДС = CтрокаСобственныеУслуги.Сумма / 118 * 18;
			КонецЕсли;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.БезНДС") Тогда
				CтрокаСобственныеУслуги.НДС = 0;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Если Объект.АгентскиеУслуги.Количество()  > 0 Тогда 
		Для Каждого CтрокаАгентскиеУслуги Из Объект.АгентскиеУслуги Цикл
			CтрокаАгентскиеУслуги.СтавкаНДС = ВыбранноеЗначение;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20") Тогда
				CтрокаАгентскиеУслуги.СуммаНДС = CтрокаСобственныеУслуги.Сумма / 120 * 20;
			КонецЕсли;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС18") Тогда
				CтрокаАгентскиеУслуги.СуммаНДС = CтрокаСобственныеУслуги.Сумма / 118 * 18;
			КонецЕсли;
			Если ВыбранноеЗначение = ПредопределенноеЗначение("Перечисление.СтавкиНДС.БезНДС") Тогда
				CтрокаАгентскиеУслуги.СуммаНДС = 0;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

		ИтогСуммаНДС = Объект.АгентскиеУслуги.Итог("СуммаНДС") + Объект.СобственныеУслуги.Итог("НДС");
		Объект.СуммаДокумента = Объект.АгентскиеУслуги.Итог("Всего") + Объект.СобственныеУслуги.Итог("Всего");

			УстановитьЗаголовкиКолонок();

	Модифицированность = Истина;

КонецПроцедуры

&НаСервере
Процедура УстановитьЗаголовкиКолонок()
	
	ЗаголовокВознаграждение = ?(Объект.АгентскиеУслуги.Итог("СуммаНДС") > 0, НСтр("ru='Вознаграждение с НДС'"), НСтр("ru='Вознаграждение без НДС'"));
	
	Элементы.АгентскиеУслугиСуммаВознаграждения.Заголовок = ЗаголовокВознаграждение;

КонецПроцедуры

&НаКлиенте
Процедура СпособРасчетаКомиссионногоВознагражденияПриИзменении(Элемент)
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьТекДокумента(Команда)
	
КонецПроцедуры

&НаКлиенте
Процедура СчетДоходовПриИзменении(Элемент)
	СчетДоходовОбработатьИзменение(ЭтаФорма);
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура СчетДоходовОбработатьИзменение(Форма)
	
	Объект = Форма.Объект;
	
	Если НЕ ЗначениеЗаполнено(Объект.СчетДоходов) Тогда
		Объект.Субконто = Неопределено;
	КонецЕсли;
	
	БухгалтерскийУчетКлиентСервер.УстановитьСвойстваСубконтоШапкиПриИзмененииСчета(
		Форма, Объект, ПараметрыУстановкиСвойствСубконто(Форма));
	
	Если НЕ ЗначениеЗаполнено(Объект.СчетДоходов) Тогда
		Форма.СчетДоходовКоличествоСубконто = 0;
	Иначе
		СвойстваСчета = БухгалтерскийУчетВызовСервераПовтИсп.ПолучитьСвойстваСчета(Объект.СчетДоходов);
		Форма.СчетДоходовКоличествоСубконто = СвойстваСчета.КоличествоСубконто;
	КонецЕсли;
	
	УправлениеФормой(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПараметрыУстановкиСвойствСубконто(Форма)
	
	Результат = БухгалтерскийУчетКлиентСервер.НовыеПараметрыУстановкиСвойствСубконто();
	
	Результат.ПоляФормы.Субконто1   = "Субконто";
	Результат.ПоляОбъекта.Субконто1 = "Субконто";
	Результат.ПоляОбъекта.СчетУчета = "СчетДоходов";
	
	Результат.ДопРеквизиты.Вставить("Организация", Форма.Объект.Организация);

	Возврат Результат;

КонецФункции

&НаКлиенте
Процедура УслугаПоВознаграждениюПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Объект.УслугаПоВознаграждению) Тогда
		УслугаПоВознаграждениюПриИзмененииНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УслугаПоВознаграждениюПриИзмененииНаСервере()

	ДанныеОбъекта	= Новый Структура("Дата, Организация");
	ЗаполнитьЗначенияСвойств(ДанныеОбъекта, Объект);
	
	СведенияОНоменклатуре = БухгалтерскийУчетПереопределяемый.ПолучитьСведенияОНоменклатуре(Объект.УслугаПоВознаграждению, ДанныеОбъекта);
	Если СведенияОНоменклатуре <> Неопределено Тогда
		
		СчетаПоУслуге = СведенияОНоменклатуре.СчетаУчета;
		Объект.СчетУчетаНДСПоРеализации	= СчетаПоУслуге.СчетУчетаНДСПродажи;
		Объект.СчетДоходов				= СчетаПоУслуге.СчетДоходов;
		
		НоменклатурнаяГруппаВознаграждения = СведенияОНоменклатуре.НоменклатурнаяГруппа;
		
		СчетДоходовОбработатьИзменение(ЭтаФорма);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	//ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры
