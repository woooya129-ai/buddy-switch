# دليل Buddy Switch بالعربية

[الملف الإنجليزي الأساسي](../../README.md) · [إعداد الشخصية واللغة](../personas.md)

Buddy Switch مثال مفتوح لتبديل ملفات Hermes الشخصية من محادثة Telegram واحدة.
يُستخدم `/friend` للمحادثة الخفيفة، و`/work` للملفات والبحث والأدوات.

## التثبيت

ثبّت Hermes أولاً وأنشئ ملفين شخصيين:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

ثم ثبّت Buddy Switch:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

عند اكتمال شريط التقدم تفتح شخصية ASCII عينيها في الطرفية، ثم يبدأ إعداد الاستخدام
الأول. بعد اختيار أسماء الملفات واللغة، تُنشأ مسودات SOUL قابلة للتعديل في:

```text
~/.config/buddy-switch/personas/<profile-name>/SOUL.md
```

لا يستبدل المثبّت أي ملف Hermes باسم `SOUL.md`. راجع المسودة قبل نسخها أو دمجها.

## إعداد Hermes

أضف هذا المقطع إلى `config.yaml` في الملفين الشخصيين:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

أعد تشغيل gateway. أرسل `/friend` أو `/work` في Telegram، وانتظر من 10 إلى 20 ثانية،
ثم أرسل الرسالة التالية.

## الشخصية واللغة

تُحدد لغة الرد في سياسة اللغة داخل `SOUL.md` لكل ملف شخصي، وليس في إعدادات التوجيه.
اختر أيضاً نموذجاً جيداً في اللغة المطلوبة. إذا لم يظهر تعديل SOUL، فابدأ جلسة جديدة
أو أعد تشغيل gateway، لأن Hermes قد يحتفظ بتعليمات النظام طوال عمر agent أو session.

## الأمثلة والأمان

الصور والأسماء مثل `@mika` و`@forge` مجرد أمثلة للتوجيه؛ لا يتضمن المستودع خمس
شخصيات مكتملة. لا تنشر الرموز السرية أو معرّفات المحادثة والمستخدم أو المسارات الخاصة
أو السجلات أو state DB أو المحادثات أو ملفات SOUL الخاصة. استخدم placeholders عند
مشاركة قائمة السماح في Telegram.
