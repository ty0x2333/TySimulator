//
//  DirectoryWatcher.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/20.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

/// https://developer.apple.com/library/content/samplecode/DocInteraction/Listings/ReadMe_txt.html
class DirectoryWatcher {
    var dirFD: Int32 = -1
    var kq: Int32 = -1
    var dirKQRef: CFFileDescriptor?
    
    private var didChange: (() -> Void)?
    
    deinit {
        invalidate()
    }
    
    class func watchFolder(path: String, didChange:(() -> Void)?) -> DirectoryWatcher? {
        let result: DirectoryWatcher = DirectoryWatcher()
        result.didChange = didChange
        if result.startMonitoring(directory: path as NSString) {
            return result
        }
        return nil
    }
    
    func invalidate() {
        if dirKQRef != nil {
            CFFileDescriptorInvalidate(dirKQRef)
            dirKQRef = nil
            // We don't need to close the kq, CFFileDescriptorInvalidate closed it instead.
            // Change the value so no one thinks it's still live.
            kq = -1
        }
        
        if dirFD != -1 {
            close(dirFD)
            dirFD = -1
        }
    }
    
    // MARK: Private
    
    func kqueueFired() {
        assert(kq >= 0)
        
        var event: kevent = kevent()
        var timeout: timespec = timespec(tv_sec: 0, tv_nsec: 0)
        let eventCount = kevent(kq, nil, 0, &event, 1, &timeout)

        assert((eventCount >= 0) && (eventCount < 2))
        
        didChange?()
        
        CFFileDescriptorEnableCallBacks(dirKQRef, kCFFileDescriptorReadCallBack)
    }
    
    func startMonitoring(directory: NSString) -> Bool {
        // Double initializing is not going to work...
        if dirKQRef == nil && dirFD == -1 && kq == -1 {
            // Open the directory we're going to watch
            dirFD = open(directory.fileSystemRepresentation, O_EVTONLY)
            if dirFD >= 0 {
                // Create a kqueue for our event messages...
                kq = kqueue()
                if kq >= 0 {
                    var eventToAdd: kevent = kevent()
                    eventToAdd.ident = UInt(dirFD)
                    eventToAdd.filter = Int16(EVFILT_VNODE)
                    eventToAdd.flags = UInt16(EV_ADD | EV_CLEAR)
                    eventToAdd.fflags = UInt32(NOTE_WRITE)
                    eventToAdd.data = 0
                    eventToAdd.udata = nil
                    
                    let errNum = kevent(kq, &eventToAdd, 1, nil, 0, nil)
                    if errNum == 0 {
                        var context = CFFileDescriptorContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
                        
                        let callback: CFFileDescriptorCallBack = { (kqRef: CFFileDescriptor?, callBackTypes: CFOptionFlags, info: UnsafeMutableRawPointer?) in
                            guard let info = info else {
                                return
                            }
                            let obj: DirectoryWatcher = Unmanaged<DirectoryWatcher>.fromOpaque(info).takeUnretainedValue()
                            assert(callBackTypes == kCFFileDescriptorReadCallBack)
                            
                            obj.kqueueFired()
                        }
                        
                        // Passing true in the third argument so CFFileDescriptorInvalidate will close kq.
                        dirKQRef = CFFileDescriptorCreate(nil, kq, true, callback, &context)
                        if dirKQRef != nil {
                            if let rls = CFFileDescriptorCreateRunLoopSource(nil, dirKQRef, 0) {
                                CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode)
                                CFFileDescriptorEnableCallBacks(dirKQRef, kCFFileDescriptorReadCallBack)
                                
                                // If everything worked, return early and bypass shutting things down
                                return true
                            }
                            // Couldn't create a runloop source, invalidate and release the CFFileDescriptorRef
                            CFFileDescriptorInvalidate(dirKQRef)
                            dirKQRef = nil
                        }
                    }
                    // kq is active, but something failed, close the handle...
                    close(kq)
                    kq = -1
                }
                // file handle is open, but something failed, close the handle...
                close(dirFD)
                dirFD = -1
            }
        }
        return false
    }
}
