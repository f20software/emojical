//
//  IconsViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/17/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol IconsViewControllerDelegate {
    func iconSelected(_ icon: String)
}

class IconsViewController: UICollectionViewController {

    private var dataSource: [String] = ["", "crosshair", "search", "zoomin", "zoomout", "binoculars", "incognito", "radar", "raisedhand", "attach", "link", "write", "compose", "lock", "unlock", "key", "backspace", "ban", "nosmoking", "trash", "target", "stopsign", "radioactive", "skull", "skullandcrossbones", "lightning", "tag", "newtag", "flag", "like", "dislike", "heart", "addheart", "deleteheart", "star", "trophy", "award", "ribbon", "medal", "badge", "crown", "bullseye", "sample", "crop", "layers", "magicwand", "cut", "cutpaste", "clipboard", "rules", "rulerpencil", "gridlines", "pen", "pencilbrush", "pencilbrushpen", "brush", "paintroller", "fill", "stroke", "ink", "crayons", "palette", "fliphorizontally", "flipvertically", "effects", "bezier", "pixels", "phone", "rotaryphone", "touchtonephone", "phonebook", "voicemail", "headset", "megaphone", "rss", "satellitedish", "podcast", "mailbox", "send", "mail", "incomingmail", "inbox", "inboxes", "outbox", "stamp", "chat", "chats", "textchat", "exclamationchat", "questionchat", "ellipsischat", "sleep", "ampersand", "smile", "frown", "toothsmile", "toothlesssmile", "user", "users", "usergroup", "adduser", "removeuser", "deleteuser", "heartuser", "males", "females", "malefemale", "userportrait", "userframe", "usersframe", "baby", "swaddledbaby", "robot", "happyrobot", "alien", "ghost", "userprofile", "contacts", "addressbook", "footsteps", "cart", "shoppingbag", "gift", "store", "cashregister", "safe", "bill", "creditcard", "dollarsign", "eurosign", "poundsign", "yensign", "banknote", "eurobanknote", "poundbanknote", "yenbanknote", "coins", "moneybag", "calculator", "bank", "scales", "gavel", "meeting", "barchart", "piechart", "activity", "flowchart", "box", "crate", "hook", "weight", "home", "fence", "buildings", "bridge", "barn", "lodging", "warehouse", "school", "castle", "earth", "globe", "compass", "signpost", "map", "location", "pushpin", "code", "floppydisk", "script", "playscript", "stopscript", "recordscript", "bug", "puzzle", "window", "database", "adddatabase", "deletedatabase", "hdd", "networkhdd", "downloadhdd", "airplay", "music", "guitar", "mic", "headphones", "volume", "radio", "phonograph", "disc", "discs", "playlist", "musichome", "itunes", "camera", "picture", "pictures", "searchpicture", "video", "clapboard", "film", "filmroll", "playfilm", "tv", "flatscreen", "projector", "videogame", "joystick", "cartridge", "play", "pause", "stop", "record", "rewind", "fastforward", "skipback", "skipforward", "eject", "shuffle", "filecabinet", "storagebox", "books", "bookspencil", "openbook", "bookinsert", "notebook", "ledger", "album", "newspaper", "spiralbound", "notepad", "notice", "grid", "thumbnails", "menu", "filter", "desktop", "laptop", "tablet", "cell", "cellbars", "battery", "mediumbattery", "emptybattery", "chargingbattery", "screwdrivermobile", "brushmobile", "pencilmobile", "door", "washer", "dryer", "birdhouse", "toilet", "toiletpaper", "spraybottle", "lightbulb", "cfl", "flashlight", "candle", "flame", "campfire", "fireplace", "lamp", "chair", "seat", "picnictable", "frame", "heartframe", "starframe", "treeframe", "flowerframe", "questionframe", "utensilsframe", "rings", "balloons", "fireworks", "easteregg", "jackolantern", "menorah", "christmastree", "teddy", "blocks", "rattle", "diaper", "pailshovel", "sweep", "headstone", "chess", "onedie", "twodie", "threedie", "fourdie", "fivedie", "sixdie", "fuzzydice", "slingshot", "bomb", "knife", "swords", "download", "downloadbox", "downloadcrate", "upload", "uploadbox", "uploadcrate", "transfer", "refresh", "sync", "wifi", "connection", "usb", "files", "addfile", "removefile", "deletefile", "searchfile", "folder", "addfolder", "removefolder", "deletefolder", "downloadfolder", "uploadfolder", "undo", "redo", "quote", "font", "anchor", "print", "fax", "shredder", "typewriter", "list", "action", "redirect", "expand", "contract", "scaleup", "scaledown", "power", "lifepreserver", "help", "info", "alert", "caution", "plus", "hyphen", "check", "delete", "dogface", "catface", "rabbitface", "bearface", "fish", "bird", "dog", "sheep", "pig", "turtle", "snake", "elephant", "whale", "bone", "tooth", "feather", "poo", "palmtree", "tree", "cactus", "leaf", "mapleleaf", "flower", "bouquet", "chestnut", "mushroom", "gem", "snowman", "settings", "dashboard", "notifications", "toggles", "switch", "switchoff", "brightness", "flashoff", "magnet", "toolbox", "tools", "hammer", "wrench", "wrenches", "wrenchpencil", "screwdriverpencil", "hammerscrewdriver", "tapemeasure", "hourglass", "clock", "stopwatch", "alarmclock", "mantelpiececlock", "watch", "counterclockwise", "calendar", "keyboardup", "keyboarddown", "heavyasterisk", "egg", "cheese", "sausage", "hotdog", "burger", "chickenleg", "turkey", "steak", "birthdaycake", "cupcake", "pancakes", "doughnut", "pizzapie", "pizza", "frenchfries", "apple", "carrot", "grapes", "bread", "cookie", "chocolatebar", "candy", "mug", "coffee", "tea", "growler", "beer", "bottle", "wine", "wineglass", "cocktail", "soda", "cup", "babybottle", "jug", "pitcher", "kettle", "pot", "salt", "pepper", "toaster", "oven", "bbq", "takeout", "paperbag", "utensils", "cookingutensils", "apron", "chef", "helmet", "graduationcap", "tophat", "glasses", "sunglasses", "tie", "tshirt", "dress", "bikini", "backpack", "hanger", "comb", "fabric", "swatch", "weave", "thread", "yarn", "crochet", "needles", "scissorsneedles", "button", "zipper", "sunface", "sun", "partlycloudy", "snowflake", "rainbow", "umbrella", "crescentmoon", "newmoon", "waxingcrescentmoon", "firstquartermoon", "waxinggibbousmoon", "fullmoon", "waninggibbousmoon", "lastquartermoon", "waningcrescentmoon", "planet", "fan", "plug", "outlet", "policecar", "car", "carrepair", "taxi", "train", "bus", "truck", "trailer", "trailerdump", "plane", "bike", "motorcycle", "boat", "sailboat", "rocket", "ufo", "squarekey", "steeringwheel", "helm", "tire", "fuel", "jerrycan", "parking", "wheelchair", "restroom", "elevator", "passport", "briefcase", "theatre", "ticket", "bowling", "golf", "billiards", "baseball", "tennis", "basketball", "football", "soccer", "hockeymask", "flaginhole", "paddles", "skiboot", "skis", "dumbbell", "hiker", "runner", "shower", "bathtub", "hottub", "exercise", "hospital", "medicalcross", "medicalbag", "bandage", "stethoscope", "syringe", "bathroomscale", "flask", "testtube", "microscope", "telescope", "atom", "dna", "fluxcapacitor", "up", "right", "down", "left", "navigateup", "navigateright", "navigatedown", "navigateleft", "share"]
    var selectedStamp = ""
    var delegate: IconsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Stamp Image"
        collectionView.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if animated {
            scrollToStamp(selectedStamp)
        }
    }
}

    
// MARK: - Navigation

extension IconsViewController {

    func scrollToStamp(_ stamp: String) {
        let index = dataSource.firstIndex(of: stamp)
        if index != nil {
            let indexPath = IndexPath(row: index!, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
}


// MARK: - UICollectionViewDataSource

extension IconsViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCell
        cell.backgroundColor = dataSource[indexPath.row] == selectedStamp ? UIColor.lightGray : UIColor.white
        cell.icon.text = dataSource[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.iconSelected(dataSource[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

