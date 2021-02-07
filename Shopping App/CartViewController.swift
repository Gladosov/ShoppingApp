//
//  CartViewController.swift
//  Shopping App
//
//  Created by Shyam Pindoria on 15/11/17.
//  Copyright © 2017 Shyam Pindoria. All rights reserved.
//

import UIKit

class CartViewContoller: DetailViewController, UITableViewDataSource, UITableViewDelegate {
 
    let model = ModelHelper.model
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalLabel: UILabel!
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        displayTotal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        
        cell.productImage.image = model.products[Int(model.cart[indexPath.row][0])].image
        cell.nameLabel.text = model.products[Int(model.cart[indexPath.row][0])].name
        cell.quantityLabel.text = "Кол-во: " + String(Int(model.cart[indexPath.row][1]))
        cell.finishLabel.text = Int(model.cart[indexPath.row][2]) == 0 ? "Finish: No Paint" : "Finish: Paint"
        cell.materialLabel.text = Int(model.cart[indexPath.row][3]) == 0 ? "Material: PLA" : "Material ABS"
        cell.priceLabel.text = "$" + String(format: "%.2f", model.cart[indexPath.row][4])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            managedContext.delete(model.storedCart[indexPath.row])
            self.model.storedCart.remove(at: indexPath.row)
            self.model.cart.remove(at: indexPath.row)
            
            do
            {
                try managedContext.save()
                tableView.reloadData()
                displayTotal()
            }
            catch let error as NSError
            {
                print("Не сохранено. \(error), \(error.userInfo)")
            }
            
            if model.cart.count == 0 {
                self.editButton.title = "Изменить"
                self.tableView.setEditing(false, animated: true)
            }
            
        }
    }
    
    func displayTotal() {
        self.totalLabel.text = "$" + String(format: "%.2f", model.calculateCartTotal())
    }
    
    @IBAction func editTable(_ sender: UIBarButtonItem) {
        if model.cart.count > 0 {
            if self.tableView.isEditing {
                sender.title = "Изменить"
                self.tableView.setEditing(false, animated: true)
            } else {
                sender.title = "Готово"
                self.tableView.setEditing(true, animated: true)
            }
        }
    }
    
    @IBAction func checkout(_ sender: UIButton) {
        if model.cart.count == 0 {
            let alert = UIAlertController.init(title: "Корзина пуста", message: "Добавьте в корзину перед покупкой!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Посмотреть вещи", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "List", sender: sender)
            }))
            alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.performSegue(withIdentifier: "Checkout", sender: sender)
        }
    }
    
}
