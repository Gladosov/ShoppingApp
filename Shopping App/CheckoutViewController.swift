//
//  CheckoutViewController.swift
//  Shopping App
//
//  Created by Shyam Pindoria on 22/11/17.
//  Copyright © 2017 Shyam Pindoria. All rights reserved.
//

import UIKit

class CheckoutViewController: DetailViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var cardNumber: UITextField!
    @IBOutlet var cardExpiryMonth: UITextField!
    @IBOutlet var cardExpiryYear: UITextField!
    @IBOutlet var cardCvv: UITextField!
    
    @IBOutlet var pickerPickupPoint: UIPickerView!
    
    @IBOutlet var tableViewOrderDetails: UITableView!
    
    @IBOutlet var labelTotalPrice: UILabel!
    
    var model = ModelHelper.model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCheckout()
        
        self.tableViewOrderDetails.dataSource = self
        self.tableViewOrderDetails.delegate = self
        
        self.pickerPickupPoint.dataSource = self
        self.pickerPickupPoint.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckoutViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func configureCheckout() {
        
        pickerPickupPoint.selectedRow(inComponent: 0)
        
        labelTotalPrice.text = "$" + String(format: "%.2f", model.calculateCartTotal())
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = model.products[Int(model.cart[indexPath.row][0])].name
        cell.detailTextLabel?.text = String(Int(model.cart[indexPath.row][1])) + " x $" + String(format: "%.2f", model.cart[indexPath.row][4])
        
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.pickUpLocations.count
    }
    
   
    
    @IBAction func payNow(_ sender: Any) {
        
        var error = ""
        
        
        if self.model.cart.count == 0 {
            error = "Корзина пуста"
        }
        else if (self.cardNumber.text?.isEmpty)! {
            error = "Введите карту"
        }
        else if (self.cardExpiryMonth.text?.isEmpty)! {
            error = "Введите месяц"
        }
        else if (self.cardExpiryYear.text?.isEmpty)! {
            error = "Введите год"
        }
        else if (self.cardCvv.text?.isEmpty)!{
            error = "Введите CVV код"
        }
        
        
        
        if error.isEmpty {
            
            showAlertMsg("Подтвердить покупку", message: "Заплатить" + labelTotalPrice.text!, style: UIAlertControllerStyle.actionSheet)
            
        }
        else {
            showAlertMsg("Error", message: error, style: UIAlertControllerStyle.alert)
        }
        
    }
    
    var alertController: UIAlertController?
    
    func showAlertMsg(_ title: String, message: String, style: UIAlertControllerStyle) {
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if style == UIAlertControllerStyle.actionSheet {
            alertController?.addAction(UIAlertAction(title: "Заплатить", style: .default, handler: { _ in
                self.checkout()
            }))
            
            alertController?.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        } else {
            alertController?.addAction(UIAlertAction(title: "Да", style: .default))
        }
        
        self.present(self.alertController!, animated: true, completion: nil)
        
    }
    
    func checkout() {
        
        var success = true
        
        for count in 0...self.model.cart.count - 1 {
            
            let product = self.model.products[Int(self.model.cart[count][0])]
            let quantity = Int(self.model.cart[count][1])
            let total = self.model.cart[count][4]
            let material = self.model.cart[count][3] == 0.0 ? "pla" : "abs"
            let painting = self.model.cart[count][2] == 0.0 ? "false" : "true"
            
            
            let temp = self.model.purchase(product: product, quantity: quantity, total: total, material: material, painting: painting)
            
            if !temp {
                success = false
            }
            
        }
        
        if !success {
            let error = "Произошла ошибка, Попробуйте снова"
            showAlertMsg("Error", message: error, style: UIAlertControllerStyle.alert)
            
        } else {
            print("Успешно! Заказ оформлен!")
            
            self.cardNumber.text = "XXXX XXXX XXXX XXXX"
            self.cardExpiryMonth.text = "MM"
            self.cardExpiryYear.text = "YYYY"
            self.cardCvv.text = "XXX"
            
            self.labelTotalPrice.text = "$0.00"
            
            self.model.clearCart()
            self.tableViewOrderDetails.reloadData()
            
            self.performSegue(withIdentifier: "Thankyou", sender: self)
            
        }
        
    }
    
    
    
    
}
