
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр Порционность продукта
	Движения.ПорционностьПродукта.Записывать = Истина;
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ПорционностьПродукта.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура 	  = ТекСтрокаТовары.Номенклатура;
		Движение.КоличествоПорций = ТекСтрокаТовары.КоличествоПорций;
	КонецЦикла;

КонецПроцедуры
