package ru.dimorinny.showcasecard;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.support.annotation.ColorRes;
import android.support.annotation.DrawableRes;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import ru.dimorinny.showcasecard.position.Position;
import ru.dimorinny.showcasecard.position.ShowCasePosition;
import ru.dimorinny.showcasecard.position.ViewPosition;
import ru.dimorinny.showcasecard.radius.Radius;
import ru.dimorinny.showcasecard.radius.ShowCaseRadius;
import ru.dimorinny.showcasecard.radius.ViewRadius;
import ru.dimorinny.showcasecard.step.ShowCaseStepDisplayer;
import ru.dimorinny.showcasecard.util.ActivityUtils;
import ru.dimorinny.showcasecard.util.MeasuredUtils;
import ru.dimorinny.showcasecard.util.NavigationBarUtils;
import ru.dimorinny.showcasecard.util.ViewUtils;

public class ShowCaseView extends FrameLayout implements View.OnTouchListener {

    private static final float MAX_CARD_WIDTH = 0.40F;
    private static final String CARD_ANIMATION_PROPERTY = "translationY";
    private static final long CARD_ANIMATION_DURATION = 200L;
    private static final long VIEW_FADE_IN_DURATION = 200L;
    private static final long ANIMATION_START_DELAY = 20L;

    private final int CARD_PADDING_VERTICAL = ViewUtils.convertDpToPx(this, 16);
    private final int CARD_PADDING_HORIZONTAL = ViewUtils.convertDpToPx(this, 8);
    private final long CARD_TO_ARROW_OFFSET = ViewUtils.convertDpToPx(this, 25);
    private final long CARD_MIN_MARGIN = ViewUtils.convertDpToPx(this, 14);
    private final long CARD_ANIMATION_OFFSET = ViewUtils.convertDpToPx(this, 16);

    private final Paint overlayPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private ShowCaseView.DismissListener dismissListener;

    private boolean hideAnimationPerforming = false;

    private PointF position;
    private ShowCasePosition typedPosition;

    private float radius = -1F;
    private ShowCaseRadius typedRadius;

    private int cardRightOffset = 0;
    private int cardLeftOffset = 0;

    private LinearLayout mainView;
    private RelativeLayout bottomView;
    private TextView cardContent;
    private TextView cardCount;
    private TextView cardNext;

    private int totalItem, currentItem;

    /**
     * True to dismiss the card on touch/click. True by default.
     */
    private boolean dismissOnTouch = true;

    @Nullable
    private TouchListener touchListener;
    /**
     * True to hide the card view (dark overlay will still be shown).
     */
    private boolean hideCard = false;

    public ShowCaseView(Context context) {
        super(context);

        initView();
        initPaints();
    }

    private void initView() {
        setAlpha(0F);
        setWillNotDraw(false);
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    }

    private void initPaints() {
        overlayPaint.setStyle(Paint.Style.FILL);
        circlePaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
    }

    private void setContent(View cardView, LinearLayout mainView, TextView contentView, String text) {
        this.mainView = mainView;
        cardContent = contentView;
        cardContent.setText(text);
        this.bottomView = mainView.findViewById(R.id.bottom_view);

        cardCount = mainView.findViewById(R.id.count);
        cardNext = mainView.findViewById(R.id.next);

        cardCount.setTextColor(ContextCompat.getColor(this.getContext(), ShowCaseStepDisplayer.colorPrimary));
        cardNext.setTextColor(ContextCompat.getColor(this.getContext(), ShowCaseStepDisplayer.colorPrimary));

        currentItem++;

        /* Display showcase item count and next/finish tip text,
         when multiple item to display */

        if (totalItem > 1) {
            cardCount.setText(currentItem + "/" + totalItem);
            cardCount.setVisibility(VISIBLE);
            cardNext.setVisibility(VISIBLE);
            if (totalItem > currentItem) {
                cardNext.setText(getResources().getString(R.string.showcase_next));
            } else {
                cardNext.setText(getResources().getString(R.string.showcase_finish));
            }
            cardNext.setOnTouchListener(this);
        } else {

            /* Don't dismiss showcase view on out side touch,
             when single item to display.
             Display Got it text and close it only click on it */

            dismissOnTouch = false;
            touchListener = null;

            cardCount.setVisibility(GONE);
            cardNext.setText(getResources().getString(R.string.showcase_got_it));
            cardNext.setVisibility(VISIBLE);
            cardNext.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (dismissListener != null) {
                        dismissListener.onDismiss();
                    }
                    hide();
                }
            });
        }
    }

    private boolean isTouchInCircle(MotionEvent touchEvent) {
        float dx = Math.abs(touchEvent.getX() - position.x);
        float dy = Math.abs(touchEvent.getY() - position.y);
        return dx <= radius && dy <= radius;
    }

    private boolean isTouchInNext(MotionEvent touchEvent) {
        Rect nextTextRect = new Rect();
        cardNext.getHitRect(nextTextRect);

        if (!nextTextRect.contains((int)touchEvent.getX(), (int)touchEvent.getY())) {
            return false;
        }
        return true;
    }

    private void removeFromWindow() {
        if (getParent() != null && getParent() instanceof ViewGroup) {
            ((ViewGroup) getParent()).removeView(this);
        }
    }

    private void initCardOffsets(Activity activity) {
        if (ActivityUtils.getOrientation(activity) == Configuration.ORIENTATION_LANDSCAPE) {
            switch (NavigationBarUtils.navigationBarPosition(activity)) {
                case LEFT:
                    cardLeftOffset = NavigationBarUtils.navigationBarHeight(activity);
                    break;
                case RIGHT:
                    cardRightOffset = NavigationBarUtils.navigationBarHeight(activity);
                    break;
                default:
                    break;
            }
        }
    }

    private int getCardWidth() {
        return (int) (getWidth() * (MAX_CARD_WIDTH + getPositionXPercentageDistanceToCenter() / 3));
    }

    public int getScreenWidth() {
        int columnWidth;
        WindowManager wm = (WindowManager) getContext()
                .getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();

        final Point point = new Point();
        try {
            display.getSize(point);
        } catch (NoSuchMethodError ignore) {
            // Older device
            point.x = display.getWidth();
            point.y = display.getHeight();
        }
        columnWidth = point.x;
        return (columnWidth/3)*2;
    }

    private double getPositionXPercentageDistanceToCenter() {
        return Math.abs(position.x - getWidth() / 2.0) / getWidth();
    }

    private int getCardGravity() {
        int vertical = (position.y <= getHeight() / 2) ? Gravity.TOP : Gravity.BOTTOM;
        int horizontal = (position.x <= getWidth() / 2) ? Gravity.START : Gravity.END;
        return vertical | horizontal;
    }

    private boolean cardFromTop() {
        return position.y > getHeight() / 2;
    }

    private boolean cardFromBottom() {
        return position.y <= getHeight() / 2;
    }

    private boolean cardFromRight() {
        return position.x <= getWidth() / 2;
    }

    private boolean cardFromLeft() {
        return position.x > getWidth() / 2;
    }

    private
    @DrawableRes
    int getCardBackgroundDrawable() {
        boolean fromBottom = cardFromBottom();
        boolean fromLeft = cardFromLeft();
        boolean fromRight = cardFromRight();
        boolean fromTop = cardFromTop();

        if (fromBottom && fromLeft) {
            return R.drawable.background_showcase_right_top;
        } else if (fromBottom && fromRight) {
            return R.drawable.background_showcase_left_top;
        } else if (fromTop && fromLeft) {
            return R.drawable.background_showcase_right_bottom;
        } else {
            return R.drawable.background_showcase_left_bottom;
        }
    }

    private int getCardMarginTop() {
        if (cardFromBottom()) {
            if (position.y + radius < CARD_MIN_MARGIN) {
                return (int) CARD_MIN_MARGIN;
            } else {
                return (int) (position.y + radius + CARD_MIN_MARGIN);
            }
        } else {
            return 0;
        }
    }

    private int getCardMarginBottom() {
        if (cardFromTop()) {
            if (position.y - radius >= getHeight() - CARD_MIN_MARGIN) {
                return (int) CARD_MIN_MARGIN;
            } else {
                return (int) (getHeight() - position.y + radius + CARD_MIN_MARGIN);
            }
        } else {
            return 0;
        }
    }

    private int getCardMarginLeft() {
        if (cardFromRight()) {
            if (position.x <= CARD_MIN_MARGIN + CARD_TO_ARROW_OFFSET + cardLeftOffset) {
                return (int) (cardLeftOffset + CARD_MIN_MARGIN);
            } else {
                return (int) (position.x - CARD_TO_ARROW_OFFSET);
            }
        } else {
            return (int) getResources().getDimension(R.dimen.padding_10);
        }
    }

    private int getCardMarginRight() {
        if (cardFromLeft()) {
            if (position.x >= getWidth() - CARD_MIN_MARGIN - CARD_TO_ARROW_OFFSET - cardRightOffset) {
                return (int) (cardRightOffset + CARD_MIN_MARGIN);
            } else {
                return (int) (getWidth() - CARD_TO_ARROW_OFFSET - position.x);
            }
        } else {
            return (int) getResources().getDimension(R.dimen.padding_10);
        }
    }

    private void configureCard(ViewGroup card) {

        card.setBackgroundResource(getCardBackgroundDrawable());
        card.addView(mainView);

        FrameLayout.LayoutParams cardLayoutParams = generateDefaultLayoutParams();
        cardLayoutParams.width = LayoutParams.WRAP_CONTENT;
        cardLayoutParams.height = LayoutParams.WRAP_CONTENT;
        cardLayoutParams.gravity = getCardGravity();
        cardLayoutParams.leftMargin = getCardMarginLeft();
        cardLayoutParams.topMargin = getCardMarginTop();
        cardLayoutParams.rightMargin = getCardMarginRight();
        cardLayoutParams.bottomMargin = getCardMarginBottom();
        card.setLayoutParams(cardLayoutParams);
    }

    private void showAfterMeasured(
            final Activity activity,
            final ViewGroup container,
            View measuredView
    ) {
        MeasuredUtils.afterOrAlreadyMeasured(measuredView, new MeasuredUtils.OnMeasuredHandler() {
            @Override
            public void onMeasured() {

                initCardOffsets(activity);

                List<View> viewsToMeasure = new ArrayList<>();

                if (typedPosition != null && typedPosition instanceof ViewPosition) {
                    viewsToMeasure.add(
                            ((ViewPosition) typedPosition).getView()
                    );
                }

                if (typedRadius != null && typedRadius instanceof ViewRadius) {
                    viewsToMeasure.add(
                            ((ViewRadius) typedRadius).getView()
                    );
                }

                if (!viewsToMeasure.isEmpty()) {
                    MeasuredUtils.afterOrAlreadyMeasuredViews(
                            viewsToMeasure,
                            new MeasuredUtils.OnMeasuredHandler() {
                                @Override
                                public void onMeasured() {
                                    position = typedPosition.getPosition(activity);
                                    radius = typedRadius.getRadius();
                                    show(container);
                                }
                            }
                    );
                } else {
                    position = typedPosition.getPosition(activity);
                    radius = typedRadius.getRadius();
                    show(container);
                }
            }
        });
    }

    /**
     * Hides the current card. Will still display the dark overlay still.
     */
    public void hideCard() {
        ((View) cardContent.getParent()).setVisibility(View.GONE);
        hideCard = true;
        invalidate();
    }

    /**
     * True to dismiss the card on touch/click. True by default.
     */
    public void setDismissOnTouch(boolean dismissOnTouch) {
        this.dismissOnTouch = dismissOnTouch;
    }


    @Override
    public void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        canvas.drawPaint(overlayPaint);

        if (!hideCard) {
            canvas.drawCircle(position.x, position.y, radius, circlePaint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (touchListener != null) {
            touchListener.onTouchEvent();
        }

        if (dismissOnTouch) {
            if (dismissListener != null) {
                dismissListener.onDismiss();
            }
            hide();
        }

        /* Only enable touch view on next text not selected view */
        return !isTouchInNext(event);
    }

    public void show(final ViewGroup container) {
        if (ViewUtils.findViewWithType(container, ShowCaseView.class) == null) {
            container.addView(this);

            final FrameLayout card = new FrameLayout(getContext());
            MeasuredUtils.afterOrAlreadyMeasured(
                    card,
                    new MeasuredUtils.OnMeasuredHandler() {
                        @Override
                        public void onMeasured() {
                            configureCard(card);

                            ObjectAnimator animator = ObjectAnimator.ofFloat(
                                    this,
                                    CARD_ANIMATION_PROPERTY,
                                    CARD_ANIMATION_OFFSET,
                                    0F
                            );

                            animator.setStartDelay(ANIMATION_START_DELAY);
                            animator.setDuration(CARD_ANIMATION_DURATION);

                            animator.start();
                        }
                    }
            );

            addView(card);
            animate()
                    .setStartDelay(ANIMATION_START_DELAY)
                    .setDuration(VIEW_FADE_IN_DURATION)
                    .alpha(1F);
        }
    }

    public void show(Activity activity) {
        ViewGroup container = (ViewGroup) activity.getWindow().getDecorView();
        showAfterMeasured(
                activity,
                container,
                container
        );
    }

    public void show(Fragment fragment) {
        showAfterMeasured(
                fragment.getActivity(),
                (ViewGroup) fragment.getActivity().getWindow().getDecorView(),
                fragment.getView()
        );
    }

    public void hide() {
        if (!hideAnimationPerforming) {

            animate()
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            hideAnimationPerforming = false;
                            removeFromWindow();
                        }

                        @Override
                        public void onAnimationStart(Animator animation) {
                            super.onAnimationStart(animation);
                            hideAnimationPerforming = true;
                        }
                    })
                    .alpha(0F);
        }
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        if (touchListener != null) {
            touchListener.onTouchEvent();
        }
        return true;
    }

    public interface DismissListener {

        void onDismiss();
    }

    public interface TouchListener {

        void onTouchEvent();
    }

    public static class Builder {

        private Context context;

        @ColorRes
        private int color = R.color.black20;
        private ShowCaseRadius radius = new Radius(128F);
        private LinearLayout mMainView;
        private TextView contentView;
        private RelativeLayout bottomView;
        private String contentText;
        private boolean dismissOnTouch = true;
        private int totalItem, currentItem;

        @Nullable
        private TouchListener touchListener;
        private DismissListener dismissListener;
        private ShowCasePosition position = new Position(
                new PointF(0F, 0F)
        );

        public Builder(Context context) {
            this.context = context;
        }

        public Builder withTypedRadius(ShowCaseRadius radius) {
            this.radius = radius;
            return this;
        }

        public Builder withTypedPosition(ShowCasePosition position) {
            this.position = position;
            return this;
        }

        public Builder withDismissListener(DismissListener listener) {
            this.dismissListener = listener;
            return this;
        }

        public Builder withColor(@ColorRes int overlayColor) {
            color = overlayColor;
            return this;
        }

        public Builder withItemCount(int totalItem, int currentItem) {
            this.totalItem = totalItem;
            this.currentItem = currentItem;
            return this;
        }

        /**
         * True to dismiss the card on touch/click. True by default.
         */
        public Builder dismissOnTouch(boolean dismissOnTouch) {
            this.dismissOnTouch = dismissOnTouch;
            return this;
        }

        public Builder withTouchListener(TouchListener touchListener) {
            this.touchListener = touchListener;
            return this;
        }

        @SuppressLint("InflateParams")
        public Builder withContent(String cardText) {
            this.mMainView = (LinearLayout) LayoutInflater.from(context).inflate(
                    R.layout.item_show_case_content,null);
            this.contentView = mMainView.findViewById(R.id.showcase_text);
            this.contentText = cardText;

            return this;
        }

        public ShowCaseView build() {
            ShowCaseView view = new ShowCaseView(context);
            view.dismissListener = this.dismissListener;
            view.typedRadius = this.radius;
            view.typedPosition = this.position;
            view.totalItem = this.totalItem;
            view.currentItem = this.currentItem;
            view.dismissOnTouch = this.dismissOnTouch;
            view.touchListener = this.touchListener;
            view.overlayPaint.setColor(ContextCompat.getColor(context, this.color));

            if (this.contentView != null && contentText != null) {
                view.setContent(view, this.mMainView, this.contentView, this.contentText);
            }

//            view.setDismissOnTouch(true);

            return view;
        }
    }
}
