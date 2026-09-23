# 中文单页简历模板 —— 一键编译
#   make            编译 main.pdf（模板本体）
#   make examples   编译 examples/ 下所有虚构示例简历到 build/examples/
#   make preview    导出模板预览图 preview.png
#   make previews   导出所有示例的预览图到 examples/previews/
#   make clean      清理中间文件与 build/
#   make distclean  连 main.pdf 一起清理
#
# 需要 TeX Live 自带的 xelatex；预览图需要 poppler-utils 的 pdftoppm。
# Overleaf 用户请手动把 Compiler 设为 XeLaTeX。

TARGET   := main
XELATEX  ?= xelatex
PDFTOPPM ?= pdftoppm
LATEXFLAGS := -interaction=nonstopmode -halt-on-error -file-line-error
AUXFILES := $(TARGET).aux $(TARGET).log $(TARGET).out $(TARGET).toc \
            $(TARGET).synctex.gz missfont.log

EXAMPLES := $(wildcard examples/*.tex)
EXNAMES  := $(notdir $(basename $(EXAMPLES)))
EXPDFS   := $(addprefix build/examples/,$(addsuffix .pdf,$(EXNAMES)))

.PHONY: all examples preview previews clean distclean

all: $(TARGET).pdf

# 跑两遍：hyperref / 目录 / 页码等在第二遍才稳定
$(TARGET).pdf: $(TARGET).tex
	$(XELATEX) $(LATEXFLAGS) $(TARGET).tex
	$(XELATEX) $(LATEXFLAGS) $(TARGET).tex

examples: $(EXPDFS)

build/examples/%.pdf: examples/%.tex
	@mkdir -p build/examples
	$(XELATEX) $(LATEXFLAGS) -output-directory=build/examples $<
	$(XELATEX) $(LATEXFLAGS) -output-directory=build/examples $<

preview: $(TARGET).pdf
	$(PDFTOPPM) -png -r 130 -singlefile $(TARGET).pdf preview

previews: examples
	@mkdir -p examples/previews
	@for name in $(EXNAMES); do \
		$(PDFTOPPM) -png -r 110 -singlefile build/examples/$$name.pdf examples/previews/$$name; \
		echo "  examples/previews/$$name.png"; \
	done

clean:
	$(RM) $(AUXFILES)
	$(RM) -r build

distclean: clean
	$(RM) $(TARGET).pdf
