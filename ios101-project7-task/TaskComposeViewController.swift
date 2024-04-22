import UIKit

class TaskComposeViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var moneyField: UITextField!  // Added IBOutlet for money input
    @IBOutlet weak var datePicker: UIDatePicker!

    var taskToEdit: Task?

    var onComposeTask: ((Task) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        if let task = taskToEdit {
            titleField.text = task.title
            noteField.text = task.note
            datePicker.date = task.dueDate
            moneyField.text = String(task.moneyRequired)  // Set money field if editing
            self.title = "Edit Task"
        }
    }

    @IBAction func didTapDoneButton(_ sender: Any) {
        guard let title = titleField.text, !title.isEmpty else {
            presentAlert(title: "Oops...", message: "Make sure to add a title!")
            return
        }
        var task: Task
        if let editTask = taskToEdit {
            task = editTask
            task.title = title
            task.note = noteField.text
            task.dueDate = datePicker.date
            task.moneyRequired = Double(moneyField.text ?? "0") ?? 0  // Update money required
        } else {
            task = Task(title: title, note: noteField.text, dueDate: datePicker.date, moneyRequired: Double(moneyField.text ?? "0") ?? 0)
        }
        onComposeTask?(task)
        dismiss(animated: true)
    }

    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
