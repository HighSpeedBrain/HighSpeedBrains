import gulp from "gulp";
import { minify } from "html-minifier-terser";
import through2 from "through2";
import { deleteAsync } from "del";
import { spawn } from "child_process";

// Clean output folder
export function clean() {
    return deleteAsync(["www/Html", "www/lib","www/index.html", "!www"]);
}

// HTML minification with full JS support
export function html() {
  gulp.parallel(tailwind)
  return gulp
    .src("src/**/*.html", { base: "src" })
    .pipe(
      through2.obj(async function (file, _, cb) {
        if (file.isBuffer()) {
          try {
            const minified = await minify(file.contents.toString(), {
              collapseWhitespace: true,
              removeComments: true,
              minifyJS: true,
              minifyCSS: true,
              removeRedundantAttributes: true,
              useShortDoctype: true,
            });

            file.contents = Buffer.from(minified);
            cb(null, file);
          } catch (err) {
            cb(err);
          }
        } else {
          cb(null, file);
        }
      })
    )
    .pipe(gulp.dest("www"));
}

// Compile Tailwind CSS using CLI (spawned)
export function tailwind(done) {
  const cmd = spawn("bunx", [
    "tailwindcss",
    "-i", "./src/Lib/tailwind.css",
    "-o", "./www/Lib/tailwind.min.css",
    "--minify",
    "--config", "./tailwind.config.js"
  ], { stdio: "inherit", shell: true });


  cmd.on("close", (code) => {
    if (code !== 0) {
      console.error(`Tailwind build failed with code ${code}`);
    }
    done();
  });
}


// Full build
export const build = gulp.series(
  clean,
  gulp.parallel(html, tailwind)
);

// Watch
export function watch() {
  gulp.watch("src/**/*.html", html);
  gulp.watch(["src/Lib/tailwind.css","./tailwind.config.js"], tailwind);
}

// Default
export default build;
