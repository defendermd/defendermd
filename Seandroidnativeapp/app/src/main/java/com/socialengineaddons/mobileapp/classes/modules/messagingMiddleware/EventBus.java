/*
 *   Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 *   You may not use this file except in compliance with the
 *   SocialEngineAddOns License Agreement.
 *   You may obtain a copy of the License at:
 *   https://www.socialengineaddons.com/android-app-license
 *   The full copyright and license information is also mentioned
 *   in the LICENSE file that was distributed with this
 *   source code.
 *
 */

package com.socialengineaddons.mobileapp.classes.modules.messagingMiddleware;

import io.reactivex.Observable;
import io.reactivex.subjects.PublishSubject;


public class EventBus {

    // Singleton instance.
    private static EventBus instance;

    private PublishSubject<Event> subject = PublishSubject.create();

    public static EventBus getInstance() {
        if (instance == null) {
            instance = new EventBus();
        }
        return instance;
    }

    /**
     * Pass any event down to event listeners.
     */
    public void passEvent(Event object) {
        try {
            subject.onNext(object);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Subscribe to this Observable. On event, do something
     * e.g. replace a fragment
     */
    public Observable<Event> getEvents() {
        return subject;
    }
}
