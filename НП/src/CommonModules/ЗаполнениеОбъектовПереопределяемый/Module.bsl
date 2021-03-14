////////////////////////////////////////////////////////////////////////////////
// Подсистема "Заполнение объектов" (сервер, переопределяемый).
// Обслуживает команды заполнения.
// Выполняется на сервере, изменяется под специфику прикладной конфигурации,
// но предназначен для использования только данной подсистемой.
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определение списка глобальных команд заполнения.
//   Событие возникает в процессе вызова модуля повторного использования.
//
// Параметры:
//   КомандыЗаполнения - ТаблицаЗначений - Таблица команд для вывода в подменю. Для изменения.
//     
//     Общие настройки:
//       * Идентификатор - Строка - Идентификатор команды.
//     
//     Настройки внешнего вида:
//       * Представление - Строка   - Представление команды в форме.
//       * Группа        - Строка   - Имя группы в командной панели, в которой будет выводиться эта команда.
//       * Порядок       - Число    - Порядок размещения команды в подменю. Используется для настройки под конкретное рабочее место.
//       * Картинка      - Картинка - Картинка команды. Необязательный.
//     
//     Настройки видимости:
//       * ТипПараметра - ОписаниеТипов - Типы объектов, для которых предназначена эта команда.
//       * ВидимостьВФормах    - Строка - Имена форм через запятую, в которых должна отображаться команда.
//                                        Используется когда состав команд отличается для различных форм.
//       * ФункциональныеОпции - Строка - Имена функциональных опций через запятую, определяющих видимость команды.
//     
//     Настройки процесса выполнения:
//       * ИмяСписка - Строка - Имя таблицы формы, связанной с динамическим списком, для которого выводится команда.
//             Используется когда в форме несколько списков и команда предназначена для второстепенного списка.
//       * МножественныйВыбор - Булево, Неопределено - Если Истина, то команда поддерживает множественный выбор.
//             В этом случае в параметре выполнения будет передан список ссылок.
//             Необязательный. Значение по умолчанию: Истина.
//       * РежимЗаписи - Строка - Действия, связанные с записью объекта, которые выполняются перед обработчиком команды.
//             ** "НеЗаписывать"          - Объект не записывается, а в параметрах обработчика вместо ссылок передается вся форма.
//                                       В этом режиме рекомендуется работать напрямую с формой,
//                                       которая передается в структуре 2 параметра обработчика команды.
//             ** "ЗаписыватьТолькоНовые" - Записывать новые объекты.
//             ** "Записывать"            - Записывать новые и модифицированные объекты.
//             ** "Проводить"             - Проводить документы.
//             Перед записью и проведением у пользователя запрашивается подтверждение.
//             Необязательный. Значение по умолчанию: "Записывать".
//       * ТребуетсяРаботаСФайлами - Булево - Если Истина, то в веб-клиенте предлагается
//             установить расширение работы с файлами.
//             Необязательный. Значение по умолчанию: Ложь.
//     
//     Настройки обработчика:
//       * Менеджер - Строка - Объект, отвечающий за выполнение команды.
//       * ИмяФормы - Строка - Имя формы, которую требуется получить для выполнения команды.
//             Если Обработчик не указан, то у формы вызывается метод "Открыть".
//       * ПараметрыФормы - Неопределено, ФиксированнаяСтруктура - Необязательный. Параметры формы, указанной в ИмяФормы.
//       * Обработчик - Строка - Описание процедуры, обрабатывающей основное действие команды.
//             Формат "<ИмяОбщегоМодуля>.<ИмяПроцедуры>" используется когда процедура размещена в общем модуле.
//             Формат "<ИмяПроцедуры>" используется в следующих случаях:
//               - Если ИмяФормы заполнено то в модуле указанной формы ожидается клиентская процедура.
//               - Если ИмяФормы не заполнено то в модуле менеджера этого объекта ожидается серверная процедура.
//       * ДополнительныеПараметры - Неопределено, ФиксированнаяСтруктура - Необязательный. Параметры обработчика, указанного в Обработчик.
//   
//   Параметры - Структура - Сведения о родительском объекте, к которому принадлежит форма и прочие параметры. Для чтения.
//       * Метаданные - ОбъектМетаданных - Метаданные объекта.
//       * ПолноеИмя  - Строка           - Полное имя объекта. Например: "Документ.ИмяДокумента".
//       * Менеджер   - Произвольный     - Модуль менеджера объекта.
//       * Ссылка     - СправочникСсылка.ИдентификаторыОбъектовМетаданных - Ссылка объекта.
//       * ЭтоЖурналДокументов - Булево - Истина если объект является журналом документов.
//   
//   СтандартнаяОбработка - Булево - Если установить в Ложь, то событие "ДобавитьКомандыЗаполнения" менеджера объекта не будет вызвано.
//
Процедура ПередДобавлениемКомандЗаполнения(КомандыЗаполнения, Параметры, СтандартнаяОбработка) Экспорт
	
КонецПроцедуры

#КонецОбласти
