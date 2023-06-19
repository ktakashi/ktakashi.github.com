(import (rnrs)
	(text markdown)
	(text sxml serializer)
	(text sxml tools)
	(getopt))

(define (usage me)
  (print me " [-s $style] [-j $script] [-t $title] file")
  (exit -1))

(define (main args)
  (with-args (cdr args)
      ((styles (#\s "style") * '())
       (scripts (#\j "javascript") * '())
       (title (#\t "title") #f "Title")
       . rest)
    (when (null? rest) (usage (car args)))
    (let ((file (car rest)))
      (call-with-input-file file
	(lambda (in)
	  (let ((node (parse-markdown markdown-parser in)))
	    (srl:sxml->html-noindent
	     `(html
	       (head
		(meta (@ (charset "utf-8")))
		(meta (@ (http-equiv "X-UA-Compatible") (content "chrome=1")))
		(meta (@ (name "viewport")
			 (content "width=device-width, initial-scale=1, maximum-scale=1")))
		,@(map (lambda (s) 
			 `(link (@ (rel "stylesheet") (href ,s))))
		       styles)
		,@(map (lambda (s) `(script (@ (src ,s)))) scripts)
		(title ,title))
	       (body
		,@(sxml:content
		   (markdown-converter:convert default-markdown-converter
					       'html node))))
	     (current-output-port))))))))
