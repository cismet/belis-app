//
//  Arbeitsprotokoll.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import MGSwipeTableCell
import SwiftForms


class Arbeitsprotokoll : GeoBaseEntity, CellInformationProviderProtocol, CellDataProvider, RightSwipeActionProvider {
    var material: String?
    var monteur: String?
    var bemerkung: String?
    var defekt: String?
    var datum: NSDate?
    var status: Status?
    var veranlassungsnummer: String?
    var protokollnummer: Int?
    
    
    var standort: Standort?
    var mauerlasche: Mauerlasche?
    var leuchte: Leuchte?
    var leitung: Leitung?
    var abzweigdose: Abzweigdose?
    var schaltstelle: Schaltstelle?
    var standaloneGeom: StandaloneGeom?
    var detailObjekt:String?
    var attachedGeoBaseEntity: GeoBaseEntity?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        material <- map["material"]
        monteur <- map["monteur"]
        bemerkung <- map["bemerkung"]
        defekt <- map["defekt"]
        datum <- (map["datum"], DateTransformFromString(format: "yyyy-MM-dd"))
        status <- map["fk_status"]
        veranlassungsnummer <- map["veranlassungsnummer"]
        protokollnummer <- map["protokollnummer"]

        standort <- map["fk_standort"]
        leuchte <- map["fk_leuchte"]
        mauerlasche <- map["fk_mauerlasche"]
        leitung <- map["fk_leitung"]
        abzweigdose <- map["fk_abzweigdose"]
        schaltstelle <- map["fk_schaltstelle"]
        standaloneGeom <- map["fk_geometrie"]
        
        if let vnr=veranlassungsnummer where vnr == "00005881" {
            print ("HIT")
        }
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        //es ist nur ein slot gefüllt
        if let gbe=standort {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Standort"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=leuchte {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Leuchte"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=mauerlasche {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Mauerlasche"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=leitung {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Leitung"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=abzweigdose {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Abzweigdose"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=schaltstelle {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Schaltstelle"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=standaloneGeom {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Freie Geometrie"
            attachedGeoBaseEntity=gbe
        }
       
    }

    override func getType() -> Entity {
        return Entity.PROTOKOLLE
    }
    
    // MARK: - CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        var nr="?"
        if let n=protokollnummer {
            nr="\(n)"
        }
        return "#\(nr) - \(attachedGeoBaseEntity?.getAnnotationTitle() ?? "")"
    }
    func getSubTitle() -> String{
        if let vnr = veranlassungsnummer {
            if let veranlassung=CidsConnector.sharedInstance().veranlassungsCache[vnr]{
                if let vbez=veranlassung.bezeichnung {
                    return "\(vbez)"
                }
                else {
                    return "V\(vnr)"
                }
            }
        }
        return "ohne Veranlassung"
    }
    func getTertiaryInfo() -> String{
        if let st=status?.bezeichnung{
            return st
        }
        else {
            return ""
        }
        
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
    
    @objc func getTitle() -> String {
        return "Protokoll"
    }
    
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }

    
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        var nr="?"
        if let n=protokollnummer {
            nr="\(n)"
        }
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Nummer",dataLeft: nr,titleRight: "Fachobjekt",dataRight: attachedGeoBaseEntity?.getAnnotationTitle() ?? "-"))
        if let vnr = veranlassungsnummer {
            if let veranlassung=CidsConnector.sharedInstance().veranlassungsCache[vnr]{
                let veranlassungDetails: [String: [CellData]] = veranlassung.getAllData()
                let veranlassungSections = veranlassung.getDataSectionKeys()
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Veranlassung",data: veranlassungsnummer ?? "ohne Veranlassung", details: veranlassungDetails, sections: veranlassungSections))
            }
        }
        
        data["Details"]=[]
        data["Details"]?.append(DoubleTitledInfoCellData(titleLeft: "Monteur", dataLeft: monteur ?? "-", titleRight: "Datum", dataRight: datum?.toDateString() ?? "-"))
        data["Details"]?.append(SingleTitledInfoCellData(title: "Status",data: status?.bezeichnung ?? "-"))
        data["Details"]?.append(MemoTitledInfoCellData(title: "Bemerkung",data: bemerkung ?? ""))
        data["Details"]?.append(MemoTitledInfoCellData(title: "Material",data: material ?? ""))
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Details","DeveloperInfo"]
    }
    
    
    
    //Kartendarstellung
    override func getAnnotationImageName() -> String{
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationImageName()
        }
        return "leuchte.png";
    }
    
    override func getAnnotationTitle() -> String{
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationTitle()
        }
        return getMainTitle();
    }
    
    override func canShowCallout() -> Bool{
        if let gbe=attachedGeoBaseEntity {
            return gbe.canShowCallout()
        }
        return true
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationCalloutGlyphIconName()
        }
        return "icon-ceilinglight"
    }
    
    func getRightSwipeActions() -> [MGSwipeButton] {
        let status=MGSwipeButton(title: "Status", backgroundColor: UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                if let protDetailView = mainVC.storyboard?.instantiateViewControllerWithIdentifier("formView") as? GenericFormViewController {
                    protDetailView.form=ProtokollStatusForm(protokoll: self, vc: protDetailView)
                    let detailNC=UINavigationController(rootViewController: protDetailView)
                    detailNC.modalInPopover=true
                    let popC=UIPopoverController(contentViewController: detailNC)
                    popC.setPopoverContentSize(CGSize(width: 400, height: 500), animated: false)
                    popC.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: .Left, animated: true)
                }
            }
            
            return true
        })
        let actions=MGSwipeButton(title: "Aktionen", backgroundColor: UIColor(red: 78.0/255.0, green: 205.0/255.0, blue: 196.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "Leuchtenerneuerung", style: .Default, handler: { alertAction in
                    // Handle Take Photo here
                }))
                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel (mit EP)", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Rundsteuerempfängerwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Sonderturnus", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Vorschaltgerätwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Sonstiges", style: .Default, handler: { alertAction in
                    if let protDetailView = mainVC.storyboard?.instantiateViewControllerWithIdentifier("formView") as? GenericFormViewController {
                        let form = FormDescriptor()
                        form.title = "Sonstiges"

                        let section2 = FormSectionDescriptor()
                        let row = FormRowDescriptor(tag: "bemerkung", rowType: .MultilineText, title: "")
                        section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
                        section2.addRow(row)
                        form.sections = [section2]
                        protDetailView.form=form

                        
                        
                        let detailNC=UINavigationController(rootViewController: protDetailView)
                        detailNC.modalInPopover=true
                        let popC=UIPopoverController(contentViewController: detailNC)
                        popC.setPopoverContentSize(CGSize(width: 500, height: 200), animated: false)
                        popC.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: .Left, animated: true)
                    }
                }))

                alertController.modalPresentationStyle = .Popover
                
                let popover = alertController.popoverPresentationController!
                popover.permittedArrowDirections = .Left
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
                
                mainVC.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return true
        })
        return [status,actions]
    }
    
    
    func getActions()-> [UIAlertAction]{
        return []
    }
    
    
    
}

class Status: BaseEntity {
    var bezeichnung: String?
    var schluessel: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        schluessel <- map["schluessel"];
    }
}



class GenericFormViewController: FormViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speichern", style: .Plain, target: self, action: "submit:")
        if let mainVC=CidsConnector.sharedInstance().mainVC {
            let image=mainVC.getGlyphedImage("icon-chevron-left", fontsize: 11, size: CGSize(width: 14, height: 14))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain , target: self, action: "cancel:")
        }
        else  {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel:")
        }

    }

    
    func submit(_: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //MARK: TODO
            print("call submit handler")
        }
    }

    func cancel(_: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //MARK: TODO
            print("call cancel handler")
        }
    }

    
    
}




class ExampleFormViewController: FormViewController {
    
    struct Static {
        static let nameTag = "name"
        static let passwordTag = "password"
        static let lastNameTag = "lastName"
        static let jobTag = "job"
        static let emailTag = "email"
        static let URLTag = "url"
        static let phoneTag = "phone"
        static let enabled = "enabled"
        static let check = "check"
        static let segmented = "segmented"
        static let picker = "picker"
        static let birthday = "birthday"
        static let categories = "categories"
        static let button = "button"
        static let stepper = "stepper"
        static let slider = "slider"
        static let textView = "textview"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "submit:")
    }
    
    /// MARK: Actions
    
    func submit(_: UIBarButtonItem!) {
        
        let message = self.form.formValues().description
        
        let alert: UIAlertView = UIAlertView(title: "Form output", message: message, delegate: nil, cancelButtonTitle: "OK")
        
        alert.show()
    }
    
    /// MARK: Private interface
    
    private func loadForm() {
        
        let form = FormDescriptor()
        
        form.title = "Example Form"
        
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: Static.emailTag, rowType: .Email, title: "Email")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "john@gmail.com", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: Static.passwordTag, rowType: .Password, title: "Password")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Enter password", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: Static.nameTag, rowType: .Name, title: "First Name")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Miguel Ángel", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section2.addRow(row)
        
        row = FormRowDescriptor(tag: Static.lastNameTag, rowType: .Name, title: "Last Name")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Ortuño", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section2.addRow(row)
        
        row = FormRowDescriptor(tag: Static.jobTag, rowType: .Text, title: "Job")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Entrepreneur", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section2.addRow(row)
        
        let section3 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: Static.URLTag, rowType: .URL, title: "URL")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. gethooksapp.com", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section3.addRow(row)
        
        row = FormRowDescriptor(tag: Static.phoneTag, rowType: .Phone, title: "Phone")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. 0034666777999", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section3.addRow(row)
        
        let section4 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: Static.enabled, rowType: .BooleanSwitch, title: "Enable")
        section4.addRow(row)
        
        row = FormRowDescriptor(tag: Static.check, rowType: .BooleanCheck, title: "Doable")
        section4.addRow(row)
        
        row = FormRowDescriptor(tag: Static.segmented, rowType: .SegmentedControl, title: "Priority")
        row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1, 2, 3]
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case 0:
                return "None"
            case 1:
                return "!"
            case 2:
                return "!!"
            case 3:
                return "!!!"
            default:
                return nil
            }
            } as TitleFormatterClosure
        
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["titleLabel.font" : UIFont.boldSystemFontOfSize(30.0), "segmentedControl.tintColor" : UIColor.redColor()]
        
        section4.addRow(row)
        
        section4.headerTitle = "An example header title"
        section4.footerTitle = "An example footer title"
        
        let section5 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: Static.picker, rowType: .Picker, title: "Gender")
        row.configuration[FormRowDescriptor.Configuration.Options] = ["F", "M", "U"]
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case "F":
                return "Female"
            case "M":
                return "Male"
            case "U":
                return "I'd rather not to say"
            default:
                return nil
            }
            } as TitleFormatterClosure
        
        row.value = "M"
        
        section5.addRow(row)
        
        row = FormRowDescriptor(tag: Static.birthday, rowType: .Date, title: "Birthday")
        section5.addRow(row)
        row = FormRowDescriptor(tag: Static.categories, rowType: .MultipleSelector, title: "Categories")
        row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1, 2, 3, 4]
        row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = true
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case 0:
                return "Restaurant"
            case 1:
                return "Pub"
            case 2:
                return "Shop"
            case 3:
                return "Hotel"
            case 4:
                return "Camping"
            default:
                return nil
            }
            } as TitleFormatterClosure
        
        section5.addRow(row)
        
        let section6 = FormSectionDescriptor()
        section6.headerTitle = "Stepper & Slider"
        
        row = FormRowDescriptor(tag: Static.stepper, rowType: .Stepper, title: "Step count")
        row.configuration[FormRowDescriptor.Configuration.MaximumValue] = 200.0
        row.configuration[FormRowDescriptor.Configuration.MinimumValue] = 20.0
        row.configuration[FormRowDescriptor.Configuration.Steps] = 2.0
        section6.addRow(row)
        
        row = FormRowDescriptor(tag: Static.slider, rowType: .Slider, title: "Slider")
        row.value = 0.5
        section6.addRow(row)
        
        let section7 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: Static.textView, rowType: .MultilineText, title: "Notes")
        section7.headerTitle = "Multiline TextView"
        section7.addRow(row)
        
        let section8 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: Static.button, rowType: .Button, title: "Dismiss")
        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
            self.view.endEditing(true)
            } as DidSelectClosure
        section8.addRow(row)
        
        form.sections = [section1, section2, section3, section4, section5, section6, section7, section8]
        
        self.form = form
    }
}
