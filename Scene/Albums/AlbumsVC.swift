//
//  AlbumsVC.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation

import UIKit
import Photos

protocol AlbumsViewControllerDelegate: class {
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection)
    func didDismissAlbumsViewController(_ albumsViewController: AlbumsViewController)
}

class AlbumsViewController: UIViewController {
    weak var delegate: AlbumsViewControllerDelegate?
        var settings: Settings! {
        didSet { dataSource?.settings = settings }
    }

    var albums: [PHAssetCollection] = []
    private var dataSource: AlbumsTableViewDataSource?
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private let lineView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = AlbumsTableViewDataSource(albums: albums)
        dataSource?.settings = settings

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = .leastNormalMagnitude
        tableView.sectionFooterHeight = .leastNormalMagnitude
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.identifier)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        let lineHeight: CGFloat = 0.5
        lineView.frame = view.bounds
        lineView.frame.size.height = lineHeight
        lineView.frame.origin.y = view.frame.size.height - lineHeight
        lineView.backgroundColor = .gray
        lineView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.addSubview(lineView)

        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 320, height: 300)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Since AlbumsViewController is presented with a presentation controller
        // And we change the state of the album button depending on if it's presented or not
        // We need to get some sort of callback to update that state.
        // Perhaps do something else
        if isBeingDismissed {
            delegate?.didDismissAlbumsViewController(self)
        }
    }
}

extension AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        delegate?.albumsViewController(self, didSelectAlbum: album)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
