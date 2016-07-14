//
//  ViewController.swift
//  GithubDemo
//
//  Created by Nhan Nguyen on 5/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit
import MBProgressHUD

// Main ViewController
class RepoResultsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var searchBar: UISearchBar!
  var searchSettings = GithubRepoSearchSettings()

  var repos = [GithubRepo]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize the UISearchBar
    searchBar = UISearchBar()
    searchBar.delegate = self

    // Add SearchBar to the NavigationBar
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar

    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableFooterView = UIView()

    // Perform the first search when the view controller first loads
    doSearch()
  }

  // Perform the search.
  private func doSearch() {
    GithubRepoSearchSettings.sharedInstance.searchString = searchBar.text

    MBProgressHUD.showHUDAddedTo(self.view, animated: true)

    // Perform request to GitHub API to get the list of repositories
    GithubRepo.fetchRepos(searchSettings, successCallback: { (newRepos) -> Void in

      // Print the returned repositories to the output window
      for repo in newRepos {
        print(repo)
      }
      self.repos.removeAll()
      self.repos.appendContentsOf(newRepos)
      self.tableView.reloadData()

      MBProgressHUD.hideHUDForView(self.view, animated: true)
      }, error: { (error) -> Void in
        print(error)
    })
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ResultsToSettings" {
      if let nvc = segue.destinationViewController as? UINavigationController, settingsVC = nvc.topViewController as? SettingsViewController {
        settingsVC.delegate = self
      }
    }
  }

}

// SearchBar methods
extension RepoResultsViewController: UISearchBarDelegate {

  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(true, animated: true)
    return true
  }

  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(false, animated: true)
    return true
  }

  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    doSearch()
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchSettings.searchString = searchBar.text
    searchBar.resignFirstResponder()
    doSearch()
  }
}

extension RepoResultsViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repos.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("GithubCell", forIndexPath: indexPath) as! GithubCell
    cell.repo = repos[indexPath.row]
    return cell
  }

}

extension RepoResultsViewController: SettingsViewControllerDelegate {

  func settingsViewControllerDidUpdate(settingsViewController: SettingsViewController) {
    doSearch()
  }

}