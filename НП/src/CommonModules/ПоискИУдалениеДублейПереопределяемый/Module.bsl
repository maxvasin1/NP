////////////////////////////////////////////////////////////////////////////////
// Подсистема "Поиск и удаление дублей".
//  
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определить объекты, в модулях менеджеров которых предусмотрена возможность параметризации 
//   алгоритма поиска дублей с помощью экспортных процедур ПараметрыПоискаДублей, ПриПоискеДублей 
//   и ВозможностьЗаменыЭлементов.
//
// Параметры:
//   Объекты - Соответствие - Объекты, в модулях менеджеров которых размещены экспортные процедуры.
//       ** Ключ     - Строка - Полное имя объекта метаданных, подключенного к подсистеме "Поиск и удаление дублей".
//       ** Значение - Строка - Имена экспортных процедур, определенных в модуле менеджера.
//           Могут быть перечислены:
//           "ПараметрыПоискаДублей",
//           "ПриПоискеДублей",
//           "ВозможностьЗаменыЭлементов".
//           Каждое имя должно начинаться с новой строки.
//           Если указана пустая строка, значит в модуле менеджера определены все процедуры.
//
// Примеры:
//
//  1. Определены все процедуры.
//	Объекты.Вставить(Метаданные.Документы.ЗаказПокупателя.ПолноеИмя(), "");
//
//  2. Определены процедуры ПараметрыПоискаДублей и ПриПоискеДублей.
//	Объекты.Вставить(Метаданные.БизнесПроцессы.ЗаданиеСРолевойАдресацией.ПолноеИмя(), "ПараметрыПоискаДублей
//		|ПриПоискеДублей");
//
Процедура ПриОпределенииОбъектовСПоискомДублей(Объекты) Экспорт
	
	
	
КонецПроцедуры

#КонецОбласти
