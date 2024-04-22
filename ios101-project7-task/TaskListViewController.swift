import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!  // Added IBOutlet for displaying total money

    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Style the table view
         tableView.backgroundColor = UIColor.systemGroupedBackground
         tableView.separatorColor = UIColor.lightGray

         // Style the empty state label
         emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
         emptyStateLabel.textColor = UIColor.gray

         // Style the total money label
         totalMoneyLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
         totalMoneyLabel.textColor = UIColor.systemBlue
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTasks()
    }

    @IBAction func didTapNewTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,
               let composeViewController = composeNavController.topViewController as? TaskComposeViewController {
                composeViewController.taskToEdit = sender as? Task
                composeViewController.onComposeTask = { [weak self] task in
                    task.save()
                    self?.refreshTasks()
                }
            }
        }
    }

    private func refreshTasks() {
        var tasks = Task.getTasks()
        tasks.sort { lhs, rhs in
            if lhs.isComplete && rhs.isComplete {
                return lhs.completedDate! < rhs.completedDate!
            } else if !lhs.isComplete && !rhs.isComplete {
                return lhs.createdDate < rhs.createdDate
            } else {
                return !lhs.isComplete && rhs.isComplete
            }
        }
        self.tasks = tasks
        emptyStateLabel.isHidden = !tasks.isEmpty
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        updateTotalMoney()  // Update total money display
    }

    private func updateTotalMoney() {
        let totalMoney = tasks.filter { !$0.isComplete }.reduce(0) { $0 + $1.moneyRequired }
        totalMoneyLabel.text = "Total Money: \(totalMoney)"
    }

}

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task, onCompleteButtonTapped: { [weak self] task in
            task.save()
            self?.refreshTasks()
        })
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            Task.save(tasks)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "ComposeSegue", sender: selectedTask)
    }
}
