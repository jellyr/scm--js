function caar(x){return (car)((car)(x))};
function cadr(x){return (car)((cdr)(x))};
function cdar(x){return (cdr)((car)(x))};
function cddr(x){return (cdr)((cdr)(x))};
function caaar(x){return (car)((car)((car)(x)))};
function caadr(x){return (car)((car)((cdr)(x)))};
function cadar(x){return (car)((cdr)((car)(x)))};
function caddr(x){return (car)((cdr)((cdr)(x)))};
function cdraar(x){return (cdr)((car)((car)(x)))};
function cdadr(x){return (cdr)((car)((cdr)(x)))};
function cddar(x){return (cdr)((cdr)((car)(x)))};
function cdddr(x){return (cdr)((cdr)((cdr)(x)))};
function caaaar(x){return (car)((car)((car)((car)(x))))};
function caaadr(x){return (car)((car)((car)((cdr)(x))))};
function caadar(x){return (car)((car)((cdr)((car)(x))))};
function caaddr(x){return (car)((car)((cdr)((cdr)(x))))};
function cadaar(x){return (car)((cdr)((car)((car)(x))))};
function cadadr(x){return (car)((cdr)((car)((cdr)(x))))};
function caddar(x){return (car)((cdr)((cdr)((car)(x))))};
function cadddr(x){return (car)((cdr)((cdr)((cdr)(x))))};
function cdaaar(x){return (cdr)((car)((car)((car)(x))))};
function cdaadr(x){return (cdr)((car)((car)((cdr)(x))))};
function cdadar(x){return (cdr)((car)((cdr)((car)(x))))};
function cdaddr(x){return (cdr)((car)((cdr)((cdr)(x))))};
function cddaar(x){return (cdr)((cdr)((car)((car)(x))))};
function cddadr(x){return (cdr)((cdr)((car)((cdr)(x))))};
function cdddar(x){return (cdr)((cdr)((cdr)((car)(x))))};
function cddddr(x){return (cdr)((cdr)((cdr)((cdr)(x))))};
function map(f, xs){return (runtime_dash_booleanize((null_huh_)(xs)))?(null):((cons)((f)((car)(xs)), (map)(f, (cdr)(xs))))};
function for_dash_each(f, xs){return (runtime_dash_booleanize((null_huh_)(xs)))?(null):((function(){(f)((car)(xs)); return (map)(f, (cdr)(xs))})())};
function append(x, y){return (runtime_dash_booleanize((null_huh_)(x)))?(y):((cons)((car)(x), (append)((cdr)(x), y)))};
function not(b){return (runtime_dash_booleanize(b))?(false):(true)};
function list_huh_(l){return (runtime_dash_booleanize((null_huh_)(l)))?(true):((runtime_dash_booleanize((pair_huh_)(l)))?(true):(false))};
function char_dash__gt_string(c){return c};
function list_dash__gt_string(l){return (runtime_dash_booleanize((null_huh_)(l)))?(""):((string_dash_append)((char_dash__gt_string)((car)(l)), (list_dash__gt_string)((cdr)(l))))};
function length(l){return (runtime_dash_booleanize((null_huh_)(l)))?(0):(js_dash_plus(1, (length)((cdr)(l))))};
function go(t){(display)("("); (js_dash__gt_javascript)((scm_dash__gt_js)(t)); (display)(")"); return (newline)()};
function go1(t){return (with_dash_output_dash_to_dash_string)(function(){return (go)(t)})};
function go_dash_top(t){(for_dash_each)(function(t){(js_dash__gt_javascript)((scm_dash_top_dash__gt_js)(t)); (display)(";"); return (newline)()}, t); return (newline)()};
function go_dash_top1(t){return (with_dash_output_dash_to_dash_string)(function(){return (go_dash_top)(t)})};
function compile_dash_eval(){return (display)((eval)((go_dash_top1)((read_dash_top)())))};

