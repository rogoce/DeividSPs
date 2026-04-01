-- Consulta de campos del cheque
-- Creado por: Armando Moreno M.
-- Fecha 	 : 17/07/2012

drop procedure sp_che133;

create procedure sp_che133(a_no_requis char(10)
) returning char(8),
            date,
			datetime hour to fraction(5),
			char(8),
			date,
			datetime hour to fraction(5),
			smallint,
			datetime year to fraction(5),												  
			datetime year to fraction(5),												    
			datetime year to fraction(5),												   
			char(20),
			char(20),
			smallint,
			date,
			char(8),												     
			datetime hour to fraction(5),
			smallint,
			char(2),
			char(50),
			char(30),
			date,
			datetime hour to fraction(5),
			smallint,
			date,
			smallint,
			date,
			datetime hour to fraction(5),
			char(8),
			char(30),
			char(30),
			char(30),
			char(50),
			char(30),
			char(30),
			char(30),
			char(30),
			date;


define _user_added   	   char(10);
define _n_user_added       char(30);
define _fecha_captura	   date;
define _hora_captura	   datetime hour to fraction(5);
define _aut_workflow_user  char(8);
define _n_aut_w_user       char(30);
define _aut_workflow_fecha date;
define _aut_workflow_hora  datetime hour to fraction(5);
define _aut_workflow   	   smallint;
define _fecha_firma1   	   datetime year to fraction(5);
define _fecha_firma2   	   datetime year to fraction(5);
define _fecha_paso_firma   datetime year to fraction(5);
define _firma1   		   char(20);
define _n_firma1           char(30);
define _firma2   		   char(20);
define _n_firma2           char(30);
define _en_firma   		   smallint;
define _n_en_firma         char(30);
define _fecha_impresion    date;
define _autorizado_por     char(8);
define _n_aut_por          char(30);
define _hora_impresion     datetime hour to fraction(5);
define _wf_entregado   	   smallint;
define _cod_ruta   		   char(2);
define _n_ruta             char(50);
define _wf_nombre   	   char(50);
define _wf_cedula   	   char(30);
define _wf_fecha   		   date;
define _wf_hora   		   datetime hour to fraction(5);
define _cobrado   		   smallint;
define _fecha_cobrado	   date;
define _anulado			   smallint;
define _fecha_anulado	   date;
define _hora_anulado	   datetime hour to fraction(5);
define _anulado_por		   char(8);
define _n_anulado_por      char(30);
define _fecha_estimada     date;

--SET DEBUG FILE TO "sp_che133.trc";
--tRACE ON;

SET ISOLATION TO DIRTY READ;

let _n_user_added = '';
let	_n_aut_w_user = '';
let	_firma1   	  = '';
let	_n_firma1  	  = '';
let	_firma2   	  = '';
let	_n_firma2  	  =	'';
let	_en_firma  		= '';
let	_n_en_firma		= '';
let	_autorizado_por	= '';
let	_n_aut_por     	= '';
let	_cod_ruta 		= '';
let	_n_ruta   		= '';
let	_wf_nombre		= '';
let	_wf_cedula		= '';
let	_anulado_por	= '';	
let	_n_anulado_por	= '';


  SELECT user_added,   
         fecha_captura,   
         hora_captura,   
         aut_workflow_user,   
         aut_workflow_fecha,   
         aut_workflow_hora,   
         aut_workflow,   
         fecha_firma1,   
         fecha_firma2,   
         fecha_paso_firma,   
         firma1,   
         firma2,   
         en_firma,   
         fecha_impresion,   
         autorizado_por,   
         hora_impresion,   
         wf_entregado,   
         cod_ruta,   
         wf_nombre,   
         wf_cedula,   
         wf_fecha,   
         wf_hora,   
         cobrado,   
         fecha_cobrado,   
         anulado,   
         fecha_anulado,   
         hora_anulado,   
         anulado_por
	INTO _user_added,   
		 _fecha_captura,   
		 _hora_captura,   
		 _aut_workflow_user, 
		 _aut_workflow_fecha,
		 _aut_workflow_hora, 
		 _aut_workflow,   
		 _fecha_firma1,   
		 _fecha_firma2,   
		 _fecha_paso_firma,  
		 _firma1,   
		 _firma2,   
		 _en_firma,   
		 _fecha_impresion,   
		 _autorizado_por,   
		 _hora_impresion,   
		 _wf_entregado,   
		 _cod_ruta,   
		 _wf_nombre,   
		 _wf_cedula,   
		 _wf_fecha,   
		 _wf_hora,   
		 _cobrado,   
		 _fecha_cobrado,   
		 _anulado,   
		 _fecha_anulado,   
		 _hora_anulado,   
		 _anulado_por
    FROM chqchmae   
   WHERE no_requis = a_no_requis;

   select descripcion
     into _n_user_added
	 from insuser
	where usuario = _user_added;

   select descripcion
     into _n_aut_w_user
	 from insuser
	where usuario = _aut_workflow_user;

   select descripcion
     into _n_aut_por
	 from insuser
	where usuario = _autorizado_por;

   select nombre  
     into _n_ruta
	 from chqruta
	where cod_ruta = _cod_ruta;

   select descripcion
     into _n_anulado_por
	 from insuser
	where usuario = _anulado_por;

   if _firma1 <> "" then
	   select descripcion
	     into _n_firma1
		 from insuser
		where upper(windows_user) = upper(_firma1);
   end if

   if _firma2 <> "" then
	   select descripcion
	     into _n_firma2
		 from insuser
		where upper(windows_user) = upper(_firma2);
   end if

	let _n_en_firma = "";
	if _en_firma in(0,4) then
		let _n_en_firma = "";
	elif _en_firma = "1" then
		let _n_en_firma = "EN FIRMA";
	elif _en_firma = "2" then
		let _n_en_firma = "FIRMADO";
	elif _en_firma = "5" then
		let _n_en_firma = "RECHAZADO";
	else
		let _n_en_firma = "";
	end if
	
    -- Calculo de dia estimado para entregar el cheque
	
	let _fecha_estimada = sp_che157(a_no_requis);
	
	
 return _user_added,   
		_fecha_captura,   
		_hora_captura,   
		_aut_workflow_user, 
		_aut_workflow_fecha,
		_aut_workflow_hora, 
		_aut_workflow,   
		_fecha_firma1,   
		_fecha_firma2,   
		_fecha_paso_firma,  
		_firma1,   
		_firma2,   
		_en_firma,   
		_fecha_impresion,   
		_autorizado_por,   
		_hora_impresion,   
		_wf_entregado,   
		_cod_ruta,   
		_wf_nombre,   
		_wf_cedula,   
		_wf_fecha,   
		_wf_hora,   
		_cobrado,   
		_fecha_cobrado,   
		_anulado,   
		_fecha_anulado,   
		_hora_anulado,   
		_anulado_por,
		_n_user_added,
		_n_aut_w_user,
		_n_aut_por,
		_n_ruta,
		_n_anulado_por,
		_n_firma1,
		_n_firma2,
		_n_en_firma,
		_fecha_estimada;

end procedure
