# https://github.com/ahrm/dotfiles/blob/main/lf-windows/lf_scripts/lf_preview.py

import mimetypes
import os
import pathlib
import platform
import subprocess
import sys
import zipfile
import tarfile
import base64

os_name = platform.system().lower()


def get_mimetype(path):
    return mimetypes.guess_type(path)[0]


def print_divider():
    print("-" * 80)


def check_command_exists(command):
    if os_name == "windows":
        try:
            subprocess.run(
                [command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            return True
        except FileNotFoundError:
            return False
    else:
        try:
            result = subprocess.run(
                ["which", command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            return result.returncode == 0
        except FileNotFoundError:
            return False


def reveal_zip_contents(zip_path):
    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_contents = zip_ref.namelist()

            print(f"Contents of {zip_path}:")
            for file in zip_contents:
                print(f"- {file}")
    except zipfile.BadZipFile:
        print(f"Error: The file {zip_path} is not a valid ZIP file.")
    except FileNotFoundError:
        print(f"Error: The file {zip_path} does not exist.")


def reveal_tar_contents(tar_path):
    try:
        with tarfile.open(tar_path, "r:*") as tar_ref:
            tar_contents = tar_ref.getnames()

            print(f"Contents of {tar_path}:")
            for file in tar_contents:
                print(f"- {file}")
    except tarfile.TarError:
        print(f"Error: The file {tar_path} is not a valid tar file.")
    except FileNotFoundError:
        print(f"Error: The file {tar_path} does not exist.")


def reveal_rar_contents(rar_path):
    try:
        import rarfile

        try:
            # 确保指定 unrar 工具的路径，如果它不在系统路径中
            # rarfile.UNRAR_TOOL = 'path_to_unrar_tool'
            with rarfile.RarFile(rar_path) as rf:
                rar_contents = rf.namelist()

                # 打印文件列表
                print(f"Contents of {rar_path}:")
                for file in rar_contents:
                    print(f"- {file}")
        except rarfile.Error as e:
            print(f"Error: Could not open {rar_path}. {e}")
        except FileNotFoundError:
            print(f"Error: The file {rar_path} does not exist.")
    except ImportError:
        print(
            "Install rarfile for RAR previews using `pip install rarfile`, also make sure you have unrar installed"
        )


def reveal_7z_contents(file_path):
    try:
        import py7zr

        try:
            with py7zr.SevenZipFile(file_path, mode="r") as z:
                all_files = z.getnames()  # 获取归档文件内所有文件的名称列表

                # 打印文件列表
                print(f"Contents of {file_path}:")
                for file in all_files:
                    print(f"- {file}")
        except py7zr.Bad7zFile:
            print(
                f"Error: The file {file_path} is not a valid 7z file or is corrupted."
            )
        except FileNotFoundError:
            print(f"Error: The file {file_path} does not exist.")
    except ImportError:
        print(
            "Install py7zr for 7z previews using `pip install py7zr`, also make sure you have 7z installed"
        )


def handle_text(path: str):
    if path.endswith(".md") or path.endswith(".markdown"):
        try:
            subprocess.run(["glow", path])
            return
        except Exception as e:
            print(f"Error calling glow: {e}, falling back to other text previewers")

    if check_command_exists("bat"):
        try:
            subprocess.run(
                [
                    "bat",
                    "--style",
                    "numbers,changes",
                    "--color",
                    "always",
                    "--line-range",
                    ":200",
                    path,
                ]
            )
            return
        except Exception as e:
            print(f"Error calling bat: {e}")

    text_previewers = ["cat", "less", "more"]
    for previewer in text_previewers:
        if check_command_exists(previewer):
            try:
                subprocess.run([previewer, path])
            except Exception as e:
                print(f"Error calling {previewer}: {e}")
            return


def handle_pdf(path):
    try:
        import fitz

        try:
            doc = fitz.open(path)
            num_pages = doc.page_count  # noqa
            metadata = doc.metadata
            # text = clean_text(doc.getPageText(0))
            page = doc[0]
            text = page.get_text()  # noqa
            doc.close()
            print(f"Pages: {num_pages}")
            if metadata is not None:
                print("title: ", metadata.get("title"))
            print(text)
        except Exception as e:
            print(f"Error opening PDF: {e}")
    except ImportError:
        print("Install mupdf for PDF previews using `pip install PyMuPDF`")


def clean_text(text):
    # remove all non-ascii characters
    return "".join(c for c in text if ord(c) < 128)


def call_chafa(file_path):
    try:
        subprocess.run(["chafa", file_path])
        print()
    except Exception as e:
        print(f"Error calling chafa: {e}")


def send_image_to_iterm2(
    file_path, inline=1, width="auto", height="auto", preserveAspectRatio=1
):
    if not os.path.isfile(file_path):
        print(f"File {file_path} not found.")
        return

    with open(file_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode("utf-8")

    file_name_encoded = base64.b64encode(
        os.path.basename(file_path).encode("utf-8")
    ).decode("utf-8")

    escape_sequence = (
        f"\033]1337;File="
        f"name={file_name_encoded};"
        f"size={os.path.getsize(file_path)};"
        f"inline={inline};"
        f"width={width};"
        f"height={height};"
        f"preserveAspectRatio={preserveAspectRatio}:"
        f"{encoded_string}\a"
    )

    print(escape_sequence, end="\n", flush=True)


def handle_image(path):
    if os_name == "windows":
        if check_command_exists("chafa"):
            call_chafa(path)
        else:
            print("Install chafa for image previews")
    elif os_name == "darwin":
        if check_command_exists("chafa"):
            call_chafa(path)
        else:
            print("Install chafa for image previews")
        # iTerm2 image preview
        # send_image_to_iterm2(path)
    elif os_name == "linux":
        if check_command_exists("chafa"):
            call_chafa(path)
        else:
            print("Install chafa for image previews")

    try:
        from PIL import Image

        img = Image.open(path)
        width, height = img.size
        print(f"Size: {width}*{height}")
    except ImportError:
        print("Install Pillow for image previews")

    size = pathlib.Path(path).stat().st_size
    print_divider()
    print("File Size: {}".format(format_file_size(size)))
    print("Modify Time: {}".format(format_time_t(os.path.getmtime(file_path))))
    print("Mimetype: {}".format(mimetype))
    print_divider()
    sys.exit()


def format_time_t(time_t):
    # convert time-t to date
    from datetime import datetime

    return datetime.fromtimestamp(time_t).strftime("%Y-%m-%d %H:%M:%S")


def format_file_size(size_in_bytes):
    if size_in_bytes < 1024:
        return f"{size_in_bytes} B"
    elif size_in_bytes < 1024 * 1024:
        return f"{size_in_bytes / 1024:.2f} KB"
    elif size_in_bytes < 1024 * 1024 * 1024:
        return f"{size_in_bytes / 1024 / 1024:.2f} MB"
    else:
        return f"{size_in_bytes / 1024 / 1024 / 1024:.2f} GB"


if __name__ == "__main__":
    file_path = sys.argv[1]
    mimetype = get_mimetype(file_path)

    if mimetype is None:
        mimetype = "none"

    try:
        # print image first since chafa will clear the terminal
        if mimetype.startswith("image"):
            handle_image(file_path)

        path = pathlib.Path(file_path)
        size = path.stat().st_size
        print_divider()
        print("File Size: {}".format(format_file_size(size)))
        print("Modify Time: {}".format(format_time_t(os.path.getmtime(file_path))))
        print("Mimetype: {}".format(mimetype))
        print_divider()

        if path.is_dir():
            sys.exit()
        if mimetype == "none":
            # if file size is less 100kb
            if size < 1024 * 100:
                handle_text(file_path)
        elif (
            "zip" in mimetype
            or "tar" in mimetype
            or "rar" in mimetype
            or "7z" in mimetype
            or "compressed" in mimetype
        ):
            if file_path.endswith(".zip"):
                reveal_zip_contents(file_path)
            elif file_path.endswith(".tar") or file_path.endswith(".tar.gz"):
                reveal_tar_contents(file_path)
            elif file_path.endswith(".rar"):
                reveal_rar_contents(file_path)
            elif file_path.endswith(".7z"):
                reveal_7z_contents(file_path)
        elif mimetype.startswith("text"):
            handle_text(file_path)
        elif mimetype.startswith("application/pdf"):
            handle_pdf(file_path)
        else:
            handle_text(file_path)
    except Exception as e:
        print(e)
