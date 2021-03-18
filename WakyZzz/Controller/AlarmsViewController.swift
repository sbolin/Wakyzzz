//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import CoreData

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
 //   var alarm = Alarm()
//    var alarms = [Alarm]()
    var editingIndexPath: IndexPath?
    private let notification = NotificationController()
    //MARK: Set up data store
//    lazy var coreDataController = CoreDataController()
    var fetchedResultsController: NSFetchedResultsController<AlarmEntity>!
    lazy var coreDataController = CoreDataController()

//MARK: - View Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
 //       self.navigationItem.leftBarButtonItem = self.editButtonItem
        configureTableView()
        // for now, populate Alarms
//        if alarms.count == 0 {
//            populateAlarms()
//        }
        if fetchedResultsController.fetchedObjects == nil { // no alarms set
            populateAlarms()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkNotificationStatus()
    }
    
    // Setup TableView delegate and datasource, populate alarms
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Temporary function to populate alarms with dummy data, will be removed after app works properly and user will set their own alarms
    func populateAlarms() {
// using core data
        let context = coreDataController.managedContext
        let weekDayAlarmID = UUID()
        coreDataController.createAlarmEntityWithID(id: weekDayAlarmID)
        guard let weekDayAlarmEntity = coreDataController.fetchAlarmByAlarmID(with: weekDayAlarmID) else { return }
        // Weekdays 5am
        weekDayAlarmEntity.time = 5 * 3600
        weekDayAlarmEntity.enabled = true
        for i in 1 ... 5 {
            weekDayAlarmEntity.repeatDays[i] = true
        }
        let weekEndAlarmID = UUID()
        coreDataController.createAlarmEntityWithID(id: weekEndAlarmID)
        guard let weekendAlarmEntity = coreDataController.fetchAlarmByAlarmID(with: weekEndAlarmID) else { return }
        weekendAlarmEntity.time = 9 * 3600
        weekendAlarmEntity.enabled = false
        weekendAlarmEntity.repeatDays[0] = true
        weekendAlarmEntity.repeatDays[6] = true

        coreDataController.saveContext(context: context)
        
 // using Alarm object
        /*
        // Weekdays 5am
        alarm.time = 5 * 3600
        for i in 1 ... 5 {
            alarm.repeatDays[i] = true
        }
        alarms.append(alarm)
        
        // Weekend 9am
        alarm = Alarm()
        alarm.time = 9 * 3600
        alarm.enabled = false
        alarm.repeatDays[0] = true
        alarm.repeatDays[6] = true
        alarms.append(alarm)
 */
    }
    
    //MARK: - Tableview delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
 //       return 1
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        //        return alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        let fetchedAlarm = fetchedResultsController.object(at: indexPath)
        cell.populate(caption: fetchedAlarm.localAlarmTimeString, subcaption: fetchedAlarm.repeatingDayString, enabled: fetchedAlarm.enabled)

//        if let alarm = alarm(at: indexPath) {
//            cell.populate(caption: alarm.localAlarmTimeString, subcaption: alarm.repeatingDayString, enabled: alarm.enabled)
//        }
        return cell
    }
    
    // Added didSelectRowAt method, ask Peter if needed (this way, just select row to edit details)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetAlarm") as? SetAlarmViewController {
            vc.alarmEntity = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Set up table view editing
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.deleteAlarm(at: indexPath)
        }
        delete.backgroundColor =  UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.editAlarm(at: indexPath)
        }
        edit.backgroundColor =  UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
//    func alarm(at indexPath: IndexPath) -> Alarm? {
//        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
//    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        // need to delete alarm from coredata
        tableView.beginUpdates()
        print("Deleting alarm at indexPath\(indexPath.row)")
//        alarms.remove(at: indexPath.row) // alarms.count
        coreDataController.deleteAlarmEntity(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath // What does this do?
        let alarmEntity = fetchedResultsController.object(at: indexPath)
        presentSetAlarmViewController(alarmEntity: alarmEntity) // (alarm: alarm(at: indexPath))
    }
    
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
//        alarms.insert(alarm, at: indexPath.row)
        coreDataController.createAlarmEntity()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func presentSetAlarmViewController(alarmEntity: AlarmEntity?) { // change call site from (alarm: Alarm?)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SetAlarm") as? SetAlarmViewController {
            vc.alarmEntity = alarmEntity
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - Actions
    @IBAction func addButtonPress(_ sender: Any) {
        presentSetAlarmViewController(alarmEntity: nil) // (alarm: nil)
    }
}

extension AlarmsViewController: AlarmCellDelegate {
    // AlarmCellDelegate method
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            coreDataController.changeAlarmStatus(at: indexPath, status: enabled)
//            if let alarm = self.alarm(at: indexPath) {
// need to update coredata
//               alarm.enabled = enabled
//            }
        }
    }
}

extension AlarmsViewController: SetAlarmViewControllerDelegate {
    // SetAlarmViewControllerDelegate methods
    func setAlarmViewControllerDone(alarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            print("Edited Alarm")
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            print("new Alarm added")
//            addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
            let objectCount = fetchedResultsController.fetchedObjects?.count ?? 0
            addAlarm(alarm, at: IndexPath(row: objectCount, section: 0))
        }
        editingIndexPath = nil
    }
    
    func setAlarmViewControllerCancel() {
        editingIndexPath = nil
    }
}



// use for making pre-defined Notifications
/*
 
 
 if snoozedTimes == 0 {
 type = NotificationType.turnOff
 title = "Turn Alarm Off 🔕 or Snooze? 😴"
 subtitle = "Shut off or snooze for 1 minute"
 body = "Body of notification"
 } else {
 if snoozedTimes < 3 {
 type = NotificationType.alarmSnoozed
 title = "Turn Alarm Off 🔕 or Snooze? 😴"
 subtitle = "Shut off or snooze for 1 minute"
 body = "You have snoozed \(snoozedTimes) out of 3"
 } else {
 type = NotificationType.alarmSnoozedThreeTimes
 title = "Act of Kindness Alert! ⚠️"
 subtitle = "You must perform an act of kindness to turn alarm off"
 body = "Random act of kindness: \(actOfKindness)"
 }
 }
 
 */
