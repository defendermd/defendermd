package ru.dimorinny.showcasecard.step;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.TypedValue;
import android.widget.ScrollView;

import java.util.ArrayList;
import java.util.List;

import ru.dimorinny.showcasecard.ShowCaseView;
import ru.dimorinny.showcasecard.radius.Radius;

/**
 * Created by Frank on 2017/08/16.
 * <p>
 * Controls the displaying of a list of {@link ShowCaseStep}'s one by one.
 */
public class ShowCaseStepDisplayer implements ShowCaseView.DismissListener {

    private Context context;

    @Nullable
    private Activity activity;
    @Nullable
    private Fragment fragment;
    @Nullable
    private ScrollView scrollView;

    private float showCaseRadius;
    public static int colorPrimary = 0;

    /**
     * All items to be displayed.
     */
    private List<ShowCaseStep> items = new ArrayList<>();

    @Nullable
    private ShowCaseStepScroller showCaseStepScroller;

    /**
     * Index of the currently shown item in the items list.
     */
    private int currentlyDisplayedTipIndex = -1;

    @Nullable
    private ShowCaseView showCaseView;

    private ShowCaseStepDisplayer.DismissListener dismissListener;

    /**
     * @param scrollView scrollView to use on all {@link ShowCaseStep}'s that dictate
     *                   scrolling on activation.
     */
    private ShowCaseStepDisplayer(@Nullable Activity activity, @Nullable Fragment fragment,
                                  @Nullable ScrollView scrollView, int color) {

        this.activity = activity;
        this.fragment = fragment;
        this.scrollView = scrollView;
        this.colorPrimary = color;

        //noinspection ConstantConditions
        this.context = activity != null ? activity : fragment.getContext();
        showCaseRadius = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 70f,
                context.getResources().getDisplayMetrics());

        if (scrollView != null) {
            showCaseStepScroller = new ShowCaseStepScroller(scrollView);
        }
    }

    /**
     * Starts the tip-flow. Toggles (on click) through all help items on this page.
     */
    public void start() {
        tryShowNextTip();
    }

    /**
     * Closes and resets the tips screen.
     */
    public void dismiss() {
        if (showCaseView != null) {
            showCaseView.hide();
            if (dismissListener != null) {
                dismissListener.onDismiss();
            }
        }

        currentlyDisplayedTipIndex = -1;
        items.clear();
    }

    @Override
    public void onDismiss() {
        dismiss();
    }


    public interface DismissListener {
        void onDismiss();
    }

    /**
     * Displays the next tip on the screen, or closes the tip screen if no more tips are left.
     */
    private void tryShowNextTip() {

        if (!isContextActive()) {
            return;
        }
        if (currentlyDisplayedTipIndex >= items.size() - 1) {

            // end of tips reached.
            dismiss();
        } else {

            currentlyDisplayedTipIndex++;
            displayTip(items.get(currentlyDisplayedTipIndex));
        }
    }

    /**
     * Displays one tip on the screen. Tapping the screen will dismiss it.
     *
     * @param item tip details to display.
     */
    private void displayTip(final ShowCaseStep item) {

        if (item.getPosition().getScrollPosition(scrollView) != null
                && showCaseStepScroller != null) {
            // try to scroll to the item

            if (showCaseView != null) {
                // hide last card, just show dark overlay for now:
                showCaseView.hideCard();
            }

            // scroll first, after that display the item:
            showCaseStepScroller.scrollToShowCaseStepItem(
                    item,
                    new ShowCaseStepScroller.OnCompleteListener() {
                        @Override
                        public void onComplete() {
                            doDisplayTip(item);
                        }
                    }
            );

        } else {
            // display item right away
            doDisplayTip(item);
        }
    }

    private void doDisplayTip(ShowCaseStep item) {

        if (!isContextActive()) {
            return;
        }

        if (showCaseView != null) {
            // completely remove old view now:
            showCaseView.hide();
        }

        final int myTipIndex = currentlyDisplayedTipIndex;

        if ((int)item.getRadius() > 0) {
            showCaseRadius = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, item.getRadius(),
                    context.getResources().getDisplayMetrics());
        }

        showCaseView = new ShowCaseView.Builder(context)
                .withTypedPosition(item.getPosition())
                .withTypedRadius(new Radius(showCaseRadius))
                .withDismissListener(this)
                .withItemCount(items.size(), currentlyDisplayedTipIndex)
                .dismissOnTouch(true)
                .withTouchListener(new ShowCaseView.TouchListener() {
                    @Override
                    public void onTouchEvent() {
                        if (myTipIndex == currentlyDisplayedTipIndex) {
                            tryShowNextTip();
                        }
                    }
                })
                .withContent(item.getMessage())
                .build();

        if (activity == null) {
            showCaseView.show(fragment);
        } else {
            showCaseView.show(activity);
        }
    }

    @SuppressWarnings("unused")
    public Context getContext() {
        return context;
    }

    /**
     * Adds on item to the list of items to display.
     *
     * @param item
     */
    @SuppressWarnings("unused")
    public void addStep(ShowCaseStep item) {
        items.add(item);
    }

    /**
     * Sets the list of items to display.
     *
     * @param items
     */
    @SuppressWarnings("unused")
    public void setSteps(List<ShowCaseStep> items) {
        this.items = items;
    }

    /**
     * Returns true if the attached Context is still active / not shutting down.
     */
    private boolean isContextActive() {
        if (fragment != null) {
            return fragment.isAdded();
        } else if (activity != null) {
            return !activity.isFinishing();
        }
        return true;
    }

    public static class Builder {

        @Nullable
        private Activity activity;

        ShowCaseStepDisplayer stepController;

        @Nullable
        private Fragment fragment;
        /**
         * ScrollView used on all {@link ShowCaseStep}'s that used to scroll to the View
         * on activation.
         */
        @Nullable
        private ScrollView scrollView;

        private List<ShowCaseStep> items = new ArrayList<>();

        private DismissListener dismissListener;

        private int color;

        @SuppressWarnings("unused")
        public Builder(@NonNull Fragment fragment) {
            this.fragment = fragment;
        }

        @SuppressWarnings("unused")
        public Builder(@NonNull Activity activity, int color) {
            this.activity = activity;
            this.dismissListener = (DismissListener) activity;
            this.color = color;
        }

        /**
         * ScrollView used on all {@link ShowCaseStep}'s to scroll to the View
         * on activation.
         */
        public Builder withScrollView(@Nullable ScrollView scrollView) {
            this.scrollView = scrollView;
            return this;
        }

        /**
         * Adds on item to the list of items to display.
         *
         * @param item
         */
        @SuppressWarnings("unused")
        public Builder addStep(ShowCaseStep item) {
            items.add(item);
            return this;
        }

        @SuppressWarnings("unused")
        public ShowCaseStepDisplayer build() {

            stepController =
                    new ShowCaseStepDisplayer(activity, fragment, scrollView, color);

            stepController.setSteps(items);
            stepController.dismissListener = dismissListener;

            return stepController;
        }

        public void dismissShowCaseView() {
            if (stepController != null)
                stepController.dismiss();
        }
    }
}
