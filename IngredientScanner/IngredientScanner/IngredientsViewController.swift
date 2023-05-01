//
//  IngredientsViewController.swift
//  IngredientScanner
//
//  Created by yawn on 3/18/23.
//

import UIKit

class IngredientsViewController: UIViewController {
    @IBOutlet weak var myLabel: UILabel!
    
    var barcode = "";
    
    struct Product: Codable {
        let productName: String
        let brands: String
        let categories: String
    }

    func lookupProduct(with barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            do {
                let product = try JSONDecoder().decode(Product.self, from: data)
                completion(.success(product))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lookupProduct(with: barcode) { result in
            switch result {
            case .success(let product):
                print("Product name: \(product.productName)")
                print("Brands: \(product.brands)")
                print("Categories: \(product.categories)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
