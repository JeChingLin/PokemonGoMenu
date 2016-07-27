# PokemonGoMenu

#### How to use
```
class ViewController: UIViewController, PokemonGoMenuDelegate {
    @IBOutlet var menu:PokemonGoMenu?
    override func viewDidLoad() {
        super.viewDidLoad()
        menu!.delegate = self
        menu!.parentView = self.view
    }
    
    func menu(menu: PokemonGoMenu, willDisplay button: UIButton, atIndex: Int) {
        print("\(#function)")
    }

    func menu(menu: PokemonGoMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("\(#function) - index: \(atIndex)")
    }
    
    func menuCollapsed(menu: PokemonGoMenu) {
        print("\(#function)")
    }
}
```
