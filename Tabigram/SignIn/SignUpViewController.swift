//
//  SignUpViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func mailSignUp() {
        if passwordTextField.text == confirmTextField.text {
            Auth.auth().createUser(withEmail: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "") { (user, error) in
                if error != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let user = Auth.auth().currentUser
                    if let user = user {
                        //firestoreにデータを入れる
                        //user.u
                        
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = self.nameTextField.text
                        print(Auth.auth().currentUser?.displayName)
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                // ログイン状態の保持
                                let ud = UserDefaults.standard
                                ud.set(true, forKey: "isLogin")
                                ud.synchronize()
                            }
                        }
                    } else {
                        print("Error - User not found")
                    }
                }
            }
        } else {
            print("パスワードの不一致")
        }
    }
    
}
