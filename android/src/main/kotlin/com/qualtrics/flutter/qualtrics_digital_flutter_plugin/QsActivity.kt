package com.qualtrics.flutter.qualtrics_digital_flutter_plugin

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.qualtrics.digital.IQualtricsProjectEvaluationCallback
import com.qualtrics.digital.Qualtrics
import com.qualtrics.digital.TargetingResult

class QsActivity: AppCompatActivity(){
    var close : Boolean = false
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Qualtrics.instance().evaluateProject(QsCallback())
    }

    override fun onPostResume() {
        super.onPostResume()
        if(close) {
            val closer = Intent()
            setResult(1122, closer);
            finish()
        }
    }
    private inner class QsCallback: IQualtricsProjectEvaluationCallback {
        override fun run(p0: MutableMap<String, TargetingResult>?) {
            if (p0 != null) {
                p0.forEach { entry ->
                    if (entry.value.passed()) {
                        if(entry.value.creativeType.name=="MobileEmbeddedFeedback"){
                            Qualtrics.instance().displayIntercept(this@QsActivity, entry.key)
                        }else {
                            entry.value.recordImpression();
                            entry.value.recordClick();
                            Qualtrics.instance().displayTarget(this@QsActivity, entry.value.surveyUrl);
                        }
                        close = true;
                    }
                }
            }
        }
    }
}