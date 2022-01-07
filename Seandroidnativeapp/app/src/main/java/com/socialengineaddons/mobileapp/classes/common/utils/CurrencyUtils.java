package com.socialengineaddons.mobileapp.classes.common.utils;

import android.content.Context;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.Currency;

public class CurrencyUtils {

    /**
     * Method to get currency symbol with price.
     *
     * @param isoCurrencyCode currency code.
     * @param amount          price.
     * @return return the formatted currency.
     */
    public static String getFormattedCurrencyString(String isoCurrencyCode, double amount) {

        // This formats currency values as the user expects to read them (default locale).
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();

        if (currencyFormat != null) {

            // This specifies the actual currency that the value is in, and provides the currency symbol.
            Currency currency = Currency.getInstance(isoCurrencyCode);
            // Note we don't supply a locale to this method - uses default locale to format the currency symbol.
            String symbol = currency.getSymbol();

            // Add 1 white space in case of multi character currency symbol
            if (symbol.length() > 1) {
                symbol  += " ";
            }

            /*
             * Checking amount has non zero values after decimal points or not
             * if yes then use decimal format with amount as double value
             * otherwise change it to integer
             */

            if (amount % 1 != 0) {
                // We then tell our formatter to use this symbol.
                DecimalFormatSymbols decimalFormatSymbols = ((java.text.DecimalFormat) currencyFormat).getDecimalFormatSymbols();
                decimalFormatSymbols.setCurrencySymbol(symbol);
                ((java.text.DecimalFormat) currencyFormat).setDecimalFormatSymbols(decimalFormatSymbols);

                return currencyFormat.format(amount);
            } else {
                return symbol + (int) amount;
            }
        }
        return null;
    }




    public static String getCurrencyConvertedValue (Context context, String isoCurrencyCode, double amount) {


        /* First check multi currency plugin is enabled or not
         * If enable then convert price amount to selected or default currency
         * Else use @param isoCurrencyCode (coming in response with amount) for the formatting
         * */
        if (PreferencesUtils.isMultiCurrencyEnabled(context)) {
            String currencyString;
            if (!PreferencesUtils.getSelectedCurrencyInfo(context).isEmpty()) {
                currencyString = PreferencesUtils.getSelectedCurrencyInfo(context);
            } else {
                currencyString = PreferencesUtils.getDefaultCurrency(context);
            }
            try {
                JSONObject currencyInfo = new JSONObject(currencyString);
                double rate = currencyInfo.optDouble("appliedRate");
                String code = currencyInfo.optString("code");

                amount = rate * amount;

                return getFormattedCurrencyString(code, amount);

            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else {
            return getFormattedCurrencyString(isoCurrencyCode, amount);
        }

        return String.valueOf(amount);
    }
}
