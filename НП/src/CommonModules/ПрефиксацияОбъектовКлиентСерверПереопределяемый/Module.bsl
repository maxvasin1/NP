////////////////////////////////////////////////////////////////////////////////
// Подсистема "Префиксация объектов".
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Обработчик события "При получении номера на печать".
// Событие возникает перед стандартной обработкой получения номера.
// В обработчике можно переопределить стандартное поведение системы при формировании номера на печать.
//
// Параметры:
//  НомерОбъекта                     - Строка - номер или код объекта, который обрабатывается.
//  СтандартнаяОбработка             - Булево - флаг стандартной обработки; если установить значение флага в Ложь,
//                                              то стандартная обработка формирования номера на печать выполняться
//                                              не будет.
//  УдалитьПрефиксИнформационнойБазы - Булево - признак удаления префикса информационной базы;
//                                              по умолчанию равен Ложь.
//  УдалитьПользовательскийПрефикс   - Булево - признак удаления пользовательского префикса;
//                                              по умолчанию равен Ложь.
//
// Пример реализации кода обработчика:
//
//   НомерОбъекта = ПрефиксацияОбъектовКлиентСервер.УдалитьПользовательскиеПрефиксыИзНомераОбъекта(НомерОбъекта);
//   СтандартнаяОбработка = Ложь;
//
Процедура ПриПолученииНомераНаПечать(НомерОбъекта, СтандартнаяОбработка,
	УдалитьПрефиксИнформационнойБазы, УдалитьПользовательскийПрефикс) Экспорт
	
КонецПроцедуры

#КонецОбласти
