//
//  ViewController.swift
//  Vodovoz
//
//  Created by emil kurbanov on 13.08.2024.
//

import UIKit
import Alamofire
import Kingfisher

class ViewController: UIViewController {
    
    private var categories: [Category] = []
    private var selectedCategoryIndex: Int = 0
    
    private let categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 170, height: 200)
        layout.minimumLineSpacing = 5 
       
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 8
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "ProductCell")
        return collectionView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabBar()
        setupUI()
        fetchProducts()
    }
    
    private func setupTabBar() {
        let tabBar = UITabBar()
                tabBar.translatesAutoresizingMaskIntoConstraints = false
                 
                let homeItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 0)
                let catalogItem = UITabBarItem(title: "Каталог", image: UIImage(systemName: "list.dash"), tag: 1)
                let priceItem = UITabBarItem(title: "320₽", image: UIImage(systemName: "cart.fill"), tag: 2)
                let favoriteItem = UITabBarItem(title: "Избранное", image: UIImage(systemName: "heart.fill"), tag: 3)
                let profileItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 4)

                tabBar.setItems([homeItem, catalogItem, priceItem, favoriteItem, profileItem], animated: false)
             
                view.addSubview(tabBar)
           
                NSLayoutConstraint.activate([
                    tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                    tabBar.heightAnchor.constraint(equalToConstant: 49)
                ])
            }
    
    
    private func setupUI() {
        view.addSubview(categoriesStackView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            categoriesStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            categoriesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 135),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
       
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchProducts() {
        
        fetchProducts { result  in
            switch result {
            case .success(let apiResponse):
                if apiResponse.status == "Success" {
                    
                    self.categories = apiResponse.categories
                    DispatchQueue.main.async { [ weak self ] in
                        guard let self = self else { return }
                        self.setupCategoryButtons()
                        self.collectionView.reloadData()
                    }
                } else {
                    print("ERRROOROROROR")
                }
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    func fetchProducts(completion: @escaping (Result<APIResponse, Error>) -> Void) {
        
        let url = "https://szorin.vodovoz.ru/newmobile/glavnaya/super_top.php?action=topglav"

        AF.request(url).responseDecodable(of: APIResponse.self) { response in
        
            switch response.result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    private func setupCategoryButtons() {
        for (index, category) in categories.enumerated() {
            let button = UIButton(type: .system)
            
            button.setTitle(category.name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.systemBlue, for: .highlighted)
            button.titleLabel?.numberOfLines = 0
            button.backgroundColor = .white
            button.layer.cornerRadius = 8.0
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 1.0
            button.layer.shadowOffset = CGSize(width: 1, height: 2)
            button.layer.masksToBounds = false
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            button.tag = index
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            categoriesStackView.addArrangedSubview(button)
        }
        
        
        view.layoutIfNeeded()
        updateButtonShadows()
    }


    private func updateButtonShadows() {
        for case let button as UIButton in categoriesStackView.arrangedSubviews {
    
            button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
        }
    }

    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectedCategoryIndex = sender.tag
        collectionView.reloadData()
        for button in categoriesStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.setTitleColor(.black, for: .normal)
         }
        sender.setTitleColor(.systemBlue, for: .normal)
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard categories.indices.contains(selectedCategoryIndex) else {
            return 0
        }
        return categories[selectedCategoryIndex].data.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell
        let product = categories[selectedCategoryIndex].data[indexPath.item]
      
        cell.configure(with: product)
        return cell
    }
}


class ProductCollectionViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "350" // Default value
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cart"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8.0
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isHeartSelected = false {
        didSet {
            updateHeartImage()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupHeartTapGesture()
        
        heartImageView.image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
        heartImageView.tintColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(borderView)
        borderView.addSubview(imageView)
        borderView.addSubview(priceLabel)
        borderView.addSubview(cartImageView)
        borderView.addSubview(heartImageView)

        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
       
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 10),
            priceLabel.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -10),
            
            cartImageView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -10),
            cartImageView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -10),
            cartImageView.widthAnchor.constraint(equalToConstant: 35),
            cartImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            heartImageView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 8),
            heartImageView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -8),
            heartImageView.widthAnchor.constraint(equalToConstant: 24),
            heartImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupHeartTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heartTapped))
        heartImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func heartTapped() {
        isHeartSelected.toggle()
    }
    
    private func updateHeartImage() {
        let heartSymbolName = isHeartSelected ? "heart.fill" : "heart"
        if let image = UIImage(systemName: heartSymbolName)?.withRenderingMode(.alwaysTemplate) {
            heartImageView.image = image
            heartImageView.tintColor = isHeartSelected ? .red : .black
        }
    }

    func configure(with product: Product) {
        let baseURL = "https://szorin.vodovoz.ru/"
        
        if let url = URL(string: baseURL + product.detailPicture) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
       
        if let price = product.extendedPrice?.first?.price {
            let roundedPrice = Int(price.rounded())
            let priceText = "\(roundedPrice) ₽"
            
            let attributedText = NSMutableAttributedString(string: priceText)
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: String(roundedPrice).count))
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: String(roundedPrice).count, length: 2))
            
            priceLabel.attributedText = attributedText
        } else {
            priceLabel.text = "Нет данных"
        }
    }
}
