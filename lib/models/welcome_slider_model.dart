class WelcomeSliderModel {
  String imageAssetPath;
  String title;
  String desc;

  WelcomeSliderModel({this.imageAssetPath, this.title, this.desc});

  void setImageAssetPath(String getImageAssetPath) {
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDesc(String getDesc) {
    desc = getDesc;
  }

  String getImageAssetPath() {
    return imageAssetPath;
  }

  String getTitle() {
    return title;
  }

  String getDesc() {
    return desc;
  }
}

List<WelcomeSliderModel> getSlides() {
  List<WelcomeSliderModel> slides = [];
  WelcomeSliderModel welcomeSliderModel = WelcomeSliderModel();

  //  Temp data
  //  TODO: Add appropriate data
  welcomeSliderModel.setDesc(
      "Eu fugiat adipisicing eu exercitation est cupidatat duis velit.");
  welcomeSliderModel.setTitle("First page");
  welcomeSliderModel.setImageAssetPath("assets/images/welcome.jpg");
  slides.add(welcomeSliderModel);

  welcomeSliderModel = WelcomeSliderModel();

  welcomeSliderModel.setDesc(
      "Do nisi velit laborum aliquip officia dolor aliqua est sunt eiusmod ex proident mollit.");
  welcomeSliderModel.setTitle("Second page");
  welcomeSliderModel.setImageAssetPath("assets/images/welcome.jpg");
  slides.add(welcomeSliderModel);

  welcomeSliderModel = WelcomeSliderModel();

  welcomeSliderModel
      .setDesc("Laborum officia ut non ad reprehenderit eiusmod.");
  welcomeSliderModel.setTitle("Third page");
  welcomeSliderModel.setImageAssetPath("assets/images/welcome.jpg");
  slides.add(welcomeSliderModel);

  welcomeSliderModel = WelcomeSliderModel();

  welcomeSliderModel.setDesc(
      "Occaecat cupidatat nisi sint nisi duis nostrud elit irure aliqua ea non dolore.");
  welcomeSliderModel.setTitle("Final page");
  welcomeSliderModel.setImageAssetPath("assets/images/welcome.jpg");
  slides.add(welcomeSliderModel);

  welcomeSliderModel = WelcomeSliderModel();

  return slides;
}
