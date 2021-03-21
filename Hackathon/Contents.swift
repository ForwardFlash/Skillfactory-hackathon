import PlaygroundSupport
import UIKit
import Foundation

// Протокол Данные пользователя
protocol UserData {
  var userName: String { get }            //Имя пользователя
  var userCardId: String { get }          //Номер карты
  var userCardPin: Int { get }            //Пин-код
  var userAmount: Float { get set}        //Сумма на счете пользователя
  var userBankDeposit: Float { get set}   //Банковский депозит
  var userPhone: String { get }           //Номер телефона
  var userPhoneBalance: Float { get set}  //Баланс телефона
}

// структура данные пользователя
struct User: UserData {
    var userName: String
    var userCardId: String
    var userCardPin: Int
    var userAmount: Float
    var userBankDeposit: Float
    var userPhone: String
    var userPhoneBalance: Float
}

// инициализация данных пользователя для сервера
var currentUser: UserData = User(userName: "Иванов Иван",            // ФИО
                                 userCardId: "1234 9876 5432 0000",  // Номер карты
                                 userCardPin: 111,                   // Пин-код
                                 userAmount: 15000.00,               // наличные
                                 userBankDeposit: 20000.00,          // сумма на счете пользователя
                                 userPhone: "+7(910)222-44-33",      // телефон
                                 userPhoneBalance: 100.00)           // текущий баланс телефона
print ("__________Начальные данные пользователя__________ \nНаличные: \(currentUser.userAmount) \nБаланс счета: \(currentUser.userBankDeposit) \nБаланс телефона: \(currentUser.userPhoneBalance)\n")

// Протокол по работе с банком предоставляет доступ к данным пользователя зарегистрированного в банке
protocol BankApi {
  func showUserBalance() // показать баланс пользователя
  func showUserToppedUpMobilePhoneCash(cash: Float) // показать результат пополнения баланса телефона наличными
  func showUserToppedUpMobilePhoneDeposite(deposit: Float) // показать результат пополнения баланса телефона с депозита
  func showWithdrawalDeposit(cash: Float) // показать результат списания со счета
  func showTopUpDeposit(cash: Float) // показать результат пополнения счета
  func showError(error: TextErrors) // показать ошибку обработки
 
  func checkUserPhone(phone: String) -> Bool // проверить номер телефона пользователя
  func checkMaxUserCash(cash: Float) -> Bool // проверить количество наличных денег пользователя
  func checkMaxAccountDeposit(withdraw: Float) -> Bool // проверить баланс счета пользователя
  func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool // проверить данные пользователя
 
  mutating func topUpPhoneBalanceCash(pay: Float) // пополнить баланс телефона наличными
  mutating func topUpPhoneBalanceDeposit(pay: Float) // пополнить баланс телефона с депозита
  mutating func getCashFromDeposit(cash: Float) // снять наличные с депозита
  mutating func putCashToDeposit(cash: Float) // положить деньги на депозит
}
//_______________________________________________________________________________________________________________________
// Перечисление Тексты ошибок
enum TextErrors: String {
    case authorityError = "Неверно указаны учетные данные (номер карты или ПИН-код). Проверьте данные и повторите ввод."
    case insufficientAmount  = "Недостаточная сумма внесенных наличных денег для осуществления операции."
    case insufficientDeposit = "Недостаточно денег на счете. Введите сумму в рамках баланса вашего счета."
    case wrongPhoneNumber = "Введен неверный номер телефона. Проверьте данные и повторите операцию."
    case choosePaymentMethod = "Для совершения операции вам необходимо выбрать источник списания."
}

// Перечисление Виды операций, выбранных пользователем (подтверждение выбора)
enum OperationsType: String {
    case showUserAmount = "Выполняется операция запроса баланса счета"
    case getCashFromCard = "Выполняется операция снятия наличных со счета"
    case putCashToCard = "Выполняется операция пополнения счета"
    case phoneBalanceToppedUpCash = "Выполняется операция пополнения баланса мобильного телефона наличными"
    case phoneBalanceToppedUpDeposit = "Выполняется операция пополнения баланса мобильного телефона с депозита"
}
 
// Перечисление Действия, которые пользователь может выбирать в банкомате (имитация кнопок)
enum UserActions {
    case checkBalance//Просмотреть баланс
    case getCash (depositGetAmount: Float) // Снять наличные
    case putCash (depositAddAmount: Float) // Положить наличные
    case topUpPhoneBalance (phone: String, cash: Float) // Пополнить баланс мобильного телефона
}
 
// Перечисление Способ оплаты/пополнения наличными или через депозит
enum PaymentMethod {
    case cash       // наличные
    case deposite   // депозит
}

// методы для работы с банком
class BankServer: BankApi {
    
    private var user: UserData
    
    init(user: UserData) {
        self.user = user
    }
    
    // вывод баланса
    public func showUserBalance() {
        print("Добрый день, \(user.userName)! \n\(OperationsType.showUserAmount.rawValue) \nВаш текущий баланс счета составляет: \(user.userBankDeposit) руб.")
    }
    // вывод после пополнения баланса мобильного телефона с внесенных наличных
    public func showUserToppedUpMobilePhoneCash(cash: Float) {
        print("Добрый день, \(user.userName)! \n\(OperationsType.phoneBalanceToppedUpCash.rawValue). \nВы пополнили баланс вашего телефона \(user.userPhone) наличными на \(cash) руб. \nБаланс вашего телефона составляет \(user.userPhoneBalance) руб. \nОстаток наличных денежных средств: \(user.userAmount) руб.")
    }
    // вывод после пополнения баланса мобильного телефона с депозита
    public func showUserToppedUpMobilePhoneDeposite(deposit: Float) {
        print("Добрый день, \(user.userName)! \n\(OperationsType.phoneBalanceToppedUpDeposit.rawValue). \nВы пополнили баланс вашего телефона \(user.userPhone) с лицевого счета на \(deposit) руб. \nБаланс вашего телефона составляет \(user.userPhoneBalance) руб. \nБаланс вашего вашего лицевого счета составляет \(user.userBankDeposit) руб.  \nОстаток наличных  денежных средств \(user.userAmount) руб. ")
    }
    // вывод после снятия со счета
    func showWithdrawalDeposit(cash: Float){
        print("Добрый день, \(user.userName)! \n\(OperationsType.getCashFromCard.rawValue). \nВаш баланс составляет \(user.userBankDeposit) руб. \nОстаток наличных  денежных средств \(user.userAmount) руб. ")
    }
    // вывод после пополнения счета
    func showTopUpDeposit(cash: Float){
        print("Добрый день, \(user.userName)! \n\(OperationsType.putCashToCard.rawValue). \nВаш баланс составляет \(user.userBankDeposit) руб. \nОстаток наличных  денежных средств \(user.userAmount) руб. ")
    }
    // вывод сообщения о прекращении операции
    func showError(error: TextErrors) {
        print("Уважаемый \(user.userName), \nвыполнение операции не может быть продолжено по следующей причине: \n\(error.rawValue) ")
    }
    // пополнение баланса телефона наличными
    public func topUpPhoneBalanceCash(pay: Float) {
        user.userPhoneBalance += pay
        user.userAmount -= pay
        currentUser = user // перезаписываем данные текущего пользователя
    }
    // пополнение баланса телефона с депозита
    public func topUpPhoneBalanceDeposit(pay: Float) {
        user.userPhoneBalance += pay
        user.userBankDeposit -= pay
        currentUser = user // перезаписываем данные текущего пользователя
    }
    // снятие с депозита
    public func getCashFromDeposit(cash: Float) {
        user.userAmount += cash
        user.userBankDeposit -= cash
        currentUser = user // перезаписываем данные текущего пользователя
    }
    // пополнение депозита
    public func putCashToDeposit(cash: Float) {
        user.userBankDeposit += cash
        user.userAmount -= cash
        currentUser = user // перезаписываем данные текущего пользователя
    }
    // проверка правильности номера телефона
    public func checkUserPhone(phone: String) -> Bool {
        if phone == user.userPhone {
        return true
        } else {
            return false
        }
    }
    // проверка наличия достаточной суммы наличных
    public func checkMaxUserCash(cash: Float) -> Bool {
        if cash <= user.userAmount {
            return true
        } else {
            return false
        }
    }
    // проверка наличия достаточной суммы на депозите
    public func checkMaxAccountDeposit(withdraw: Float) -> Bool {
        if withdraw <= user.userBankDeposit {
            return true
        }
                return false
        }
    // проверка номера карты
    private func checkCardId(cardId: String, user: UserData) -> Bool {
        if cardId == user.userCardId {
            return true
        }
                return false
            }
    // проверка Пин-кода
    private func checkCardPin(cardPin: Int, user: UserData) -> Bool {
        if cardPin == user.userCardPin {
            return true
        }
                return false
            }
    // проверка данных пользователя
    public func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool {
        let pinCorrect = checkCardId(cardId: userCardId, user: user)
        let idCorrect = checkCardPin(cardPin: userCardPin, user: user)
        
        if pinCorrect && idCorrect {
            return true
        } else {
            return false
        }

    }
}

//_______________________________________________________________________________________________________________________
// Банкомат, с которым мы работаем, имеет общедоступный интерфейс sendUserDataToBank
class ATM {

  private let userCardId: String
  private let userCardPin: Int
  private var someBank: BankApi
  private let action: UserActions
  private let paymentMethod: PaymentMethod?
    
  // инициализация данных пользователя
  init(userCardId: String, userCardPin: Int, someBank: BankApi, action: UserActions, paymentMethod: PaymentMethod? = nil) {
    
    self.userCardPin = userCardPin
    self.userCardId = userCardId
    self.someBank = someBank
    self.action = action
    self.paymentMethod = paymentMethod
    
    sendUserDataToBank(userCardId: userCardId, userCardPin: userCardPin, actions: action, paymentMethod: paymentMethod )
  }
 
  public final func sendUserDataToBank(userCardId: String, userCardPin: Int, actions: UserActions, paymentMethod: PaymentMethod?) {
    let isUserExist = someBank.checkCurrentUser(userCardId: userCardId, userCardPin: userCardPin)
    if isUserExist {  // проверяем данные пользователя
        switch actions {
        // проверка баланса
        case .checkBalance:
            someBank.showUserBalance()
        // снятие денег со счета
        case let .getCash(depositGetAmount: payment):
            if someBank.checkMaxAccountDeposit(withdraw: payment) { // проверка депозита
                someBank.getCashFromDeposit(cash: payment)  // снимаем
                someBank.showWithdrawalDeposit(cash: payment)    // выводим итоги
            } else { // недостаточно средств на депозите
                someBank.showError(error: .insufficientDeposit)}
        // пополнение счета
        case let .putCash(depositAddAmount: payment):
            if someBank.checkMaxUserCash(cash: payment) { // проверка наличных
                someBank.putCashToDeposit(cash: payment)  // пополняем
                someBank.showTopUpDeposit(cash: payment)  // выводим итоги
            } else { // недостаточно наличых средств
                someBank.showError(error: .insufficientAmount)}
        // пополнить баланс мобильного
        case let .topUpPhoneBalance(phone, cash):
            if someBank.checkUserPhone(phone: phone) { // проверяем номер телефона
                if paymentMethod != nil {
                    switch paymentMethod{
                    case .cash:
                        if someBank.checkMaxUserCash(cash: cash) { // проверка наличных
                            someBank.topUpPhoneBalanceCash(pay:cash) // пополняем
                            someBank.showUserToppedUpMobilePhoneCash(cash: cash) // выводим итоги
                        } else { // недостаточно наличных средств
                            someBank.showError(error: .insufficientAmount)}
                    case .deposite:
                        if someBank.checkMaxAccountDeposit(withdraw: cash) { // проверка депозита
                            someBank.topUpPhoneBalanceDeposit(pay:cash) // пополняем
                            someBank.showUserToppedUpMobilePhoneDeposite(deposit: cash) // выводим итоги
                        } else { // недостаточно средств на депозите
                            someBank.showError(error: .insufficientDeposit)}
                    case .none:
                        someBank.showError(error: .choosePaymentMethod)
                    }
                } else {  // не указан источник списания
                    someBank.showError(error: .choosePaymentMethod)}
            } else {  // неверный номер телефона
                someBank.showError(error: .wrongPhoneNumber)}
        }
    } else { // ошибка авторизации
        someBank.showError(error: .authorityError)}
  }
}

//проверка операций банкомата в консоли

/*
Операции банкомата
1 запрос баланса на банковском депозите,
2 снятие наличных с банковского депозита,
3 пополнение банковского депозита наличными,
4 пополнение баланса телефона наличными или с банковского депозита.
 */

// запрос баланса на счете
print("__________запрос баланса на счете____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.checkBalance)
print ("\n")

// проверка обработки ошибки в данных авторизации
print("__________проверка обработки ошибки в данных авторизации____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 222,
    someBank: BankServer (user: currentUser),
    action: UserActions.checkBalance)
print ("\n")

// пополнение депозита
print("__________пополнение депозита____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.putCash(depositAddAmount: 4000),
    paymentMethod: PaymentMethod.cash)
// снятие с депозита
print ("\n")

print("__________снятие наличных с депозита____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.getCash(depositGetAmount: 1200),
    paymentMethod: PaymentMethod.deposite)
print ("\n")

// ошибка пополнения баланса мобильного телефона
print("__________неверный номер телефона при пополнении____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.topUpPhoneBalance(phone: "+7(910)223-44-33", cash: 200.00),
    paymentMethod: PaymentMethod.cash)
print ("\n")

// ошибка не указан источник списания
print("__________не указан источник списания___________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.topUpPhoneBalance(phone: "+7(910)222-44-33", cash: 200.00))
print ("\n")

// пополнение баланса мобильного телефона
print("__________пополнение баланса мобильного телефона____________")
ATM(userCardId: "1234 9876 5432 0000",
    userCardPin: 111,
    someBank: BankServer (user: currentUser),
    action: UserActions.topUpPhoneBalance(phone: "+7(910)222-44-33", cash: 200.00),
    paymentMethod: PaymentMethod.deposite)
