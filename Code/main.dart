

//demo 3 pages
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

//Định nghĩa ThemeExtension để thêm Gradient vào ThemeData
@immutable
class GradientTheme extends ThemeExtension<GradientTheme> {
  final LinearGradient backgroundGradient;

  const GradientTheme({required this.backgroundGradient});

  @override
  GradientTheme copyWith({LinearGradient? backgroundGradient}) {
    return GradientTheme(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  GradientTheme lerp(ThemeExtension<GradientTheme>? other, double t) {
    if (other is! GradientTheme) return this;
    return GradientTheme(
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme App',
      theme: ThemeData(
        primaryColor: Color(0xFFA6C0FE),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 10, 8, 120),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          backgroundColor: Color.fromARGB(136, 252, 203, 203),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(36, 255, 252, 252),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Thêm gradient cho toàn app
        extensions: [
          GradientTheme(
            backgroundGradient: LinearGradient(
              colors: [Color.fromARGB(255, 144, 178, 255), Color.fromARGB(255, 248, 171, 174)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
      home: const HomePage(),
    );
  }
}

// Widget dùng Scaffold có gradient tự động
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const GradientScaffold({this.appBar, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context)
        .extension<GradientTheme>()!
        .backgroundGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    );
  }
}

//HOME
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        leading: const Icon(Icons.home),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WELCOME TO THEME DEMO!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

//PROFILE
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        leading: const Icon(Icons.manage_accounts),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
                ),
                const SizedBox(height: 20),
                Text('Nguyen Thi Uyen Phuong - 22KTMT1',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                  child: const Text('Settings'),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                FloatingActionButton.small(
                  heroTag: "backFromProfile",
                  backgroundColor: Colors.white.withOpacity(0.6),
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//SETTINGS
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
        leading: const Icon(Icons.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display options:',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: false,
              onChanged: (val) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}


/*
//Text Alignment
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Alignment', style: TextStyle(
            color: const Color.fromARGB(255, 132, 17, 17),
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal
          )),
          backgroundColor: const Color.fromARGB(255, 134, 189, 243)
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Text(
                'TextAlign.left', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình. Thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, color: Colors.red)),
              Text(
                'TextAlign.center', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình. Thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.green)),
              Text(
                'TextAlign.right', style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình. Thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 18, color: Colors.orange)),
              Text(
                'TextAlign.justify', style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình. Thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}

*/




/*
//Text Overflow
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
   Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Overflow', style: TextStyle(
            color: const Color.fromARGB(255, 132, 17, 17),
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal
          )),
          backgroundColor: const Color.fromARGB(255, 134, 189, 243)
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Văn bản gốc:',
                style: TextStyle( 
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 132, 17, 17),)
              ),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình, thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.Việc hiểu rõ và sử dụng đúng sẽ giúp giao diện ứng dụng của bạn trở nên đẹp mắt, rõ ràng và chuyên nghiệp hơn.',
                style: TextStyle(fontSize: 16)),
               SizedBox(height: 20),
              Text(
                'TextOverflow.clip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 132, 17, 17),)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình, thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.Việc hiểu rõ và sử dụng đúng sẽ giúp giao diện ứng dụng của bạn trở nên đẹp mắt, rõ ràng và chuyên nghiệp hơn.',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.clip,
                maxLines: 1),
              SizedBox(height: 20),
              Text(
                'TextOverflow.fade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 132, 17, 17),)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình, thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.Việc hiểu rõ và sử dụng đúng sẽ giúp giao diện ứng dụng của bạn trở nên đẹp mắt, rõ ràng và chuyên nghiệp hơn.',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.fade,
                maxLines: 2,),
              SizedBox(height: 20),
              Text(
                'TextOverflow.ellipsis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 132, 17, 17),)),
              Text(
                'Text Alignment giúp ta kiểm soát cách hiển thị văn bản trên màn hình, thuộc tính textAlign trong widget Text cho phép chọn các kiểu căn chỉnh phù hợp với bố cục giao diện.Việc hiểu rõ và sử dụng đúng sẽ giúp giao diện ứng dụng của bạn trở nên đẹp mắt, rõ ràng và chuyên nghiệp hơn.',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, ),
            ],
          ),
        ), 
      ),   
    );
  }
}

*/


/*
// fontSize and color
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Custom Fonts',
            style: TextStyle(
              color: Color.fromARGB(255, 132, 17, 17),
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 132, 194, 255),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                           Text(
                'Lập trình Đa Nền Tảng',
                style: TextStyle(
                  fontSize: 36,
                  color: Color.fromARGB(255, 143, 3, 3),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Lập trình Đa Nền Tảng',
                style: TextStyle(
                  fontSize: 46,
                  color: Color.fromARGB(255, 11, 2, 99),
                  fontFamily: 'UVNKeChuyen3', // font tùy chỉnh
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




*/

