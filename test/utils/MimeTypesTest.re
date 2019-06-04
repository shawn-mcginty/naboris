open OUnit;

let testSuite = () => [
  "utils/MimeTypes.getExtension returns html for .html file"
  >:: (
    _ => {
      let testFilename = "some/foo/bar.html";
      let actualExt = Naboris.MimeTypes.getExtension(testFilename);
      assert_equal(actualExt, "html");
    }
  ),
  "utils/MimeTypes.getMimeType works for .html file"
  >:: (
    _ => {
      let testFilename = "some/foo/bar.html";
      let expectedMimeType = "text/html";
      let actualMimeType = Naboris.MimeTypes.getMimeType(testFilename);
      assert_equal(actualMimeType, expectedMimeType);
    }
  ),
];