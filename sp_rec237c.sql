-- Procedure que busca las transacciones de las ordenes de un ajuste para enviarlas a WF												   
-- Creado por: Amado Perez 27/10/2014

drop procedure sp_rec237c;

create procedure sp_rec237c(a_no_ajuste char(10))
returning integer, 
          char(10), 
		  char(20), 
		  date, 
		  char(10), 
		  integer, 
		  smallint, 
		  dec(16,2),
		  char(8),
		  datetime year to fraction(5),
		  char(8),
		  datetime year to fraction(5),
		  char(8),
		  datetime year to fraction(5);

define _error           integer;
define _descripcion		varchar(50);

define _renglon             smallint;
define _no_orden            char(10);
define _no_tranrec_neg		char(10);
define _no_tranrec_pos		char(10);
define _no_tranrec_pre 		char(10);
define _no_tranrec          char(10);
define _no_reclamo  		char(10);
define _cod_sucursal		char(3);
define _periodo     		char(7);
define _fecha       		date;
define _cod_tipotran        char(3);
define _wf_incidente        integer;
define _no_ajus_orden       char(10);
define _user_added          char(8);
define _windows_user        char(20);
define _wf_aprobado         smallint;
define _numrecla            char(20);
define _transaccion         char(10);
define _monto               dec(16,2);

define _wf_apr_j            char(8);
define _wf_apr_j_fh         datetime year to fraction(5);
define _wf_apr_jt           char(8);
define _wf_apr_jt_fh        datetime year to fraction(5);
define _wf_apr_g            char(8);
define _wf_apr_g_fh         datetime year to fraction(5);

--SET DEBUG FILE TO "sp_rec233.trc"; 
--TRACE ON;                                                                

CREATE TEMP TABLE tmp_trans_wf (
	renglon      SMALLINT,
	no_orden     CHAR(10),
	no_tranrec   CHAR(10),
	no_reclamo   CHAR(10),
	cod_sucursal CHAR(3),
	periodo      CHAR(7),
	fecha        DATE,
	cod_tipotran CHAR(3),	
	PRIMARY KEY (no_tranrec)) WITH NO LOG; 

set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 	RETURN _error, null, null, null, null, null, null, null, null, null, null, null, null, null;         
END EXCEPTION

let _error = 0;
let _descripcion = "Verificacion exitosa";
let _no_tranrec_neg = null;
let _no_tranrec_pos = null;
let _no_tranrec_pre = null;
let _no_reclamo     = null;
let _cod_sucursal   = null;
let _periodo        = null;
let _fecha          = null;


foreach	
	select renglon,
		   no_orden,           
		   no_tranrec_neg,       
		   no_tranrec_pos,
		   no_tranrec_pre          
	  into _renglon,
		   _no_orden,    
		   _no_tranrec_neg,
		   _no_tranrec_pos,
		   _no_tranrec_pre    
	  from recordad
	 where no_ajus_orden = a_no_ajuste

	if _no_tranrec_neg is not null and trim(_no_tranrec_neg) <> "" then
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente,
			 wf_apr_j,
			 wf_aprobado
		into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
			 _wf_incidente,			 
			 _wf_apr_j,
			 _wf_aprobado
		from rectrmae
	   where no_tranrec = _no_tranrec_neg;
	   
		  insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_neg, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 
	  
	end if

	if _no_tranrec_pos is not null and trim(_no_tranrec_pos) <> "" then
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente,
			 wf_apr_j,
			 wf_aprobado
		into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
			 _wf_incidente,			 
			 _wf_apr_j,
			 _wf_aprobado
		from rectrmae
	   where no_tranrec = _no_tranrec_pos;

		 insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_pos, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 

	end if

	if _no_tranrec_pre is not null and trim(_no_tranrec_pre) <> "" then
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente,
			 wf_apr_j,
			 wf_aprobado
		into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
			 _wf_incidente,			 
			 _wf_apr_j,
			 _wf_aprobado
		from rectrmae
	   where no_tranrec = _no_tranrec_pre;

		  insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_pre, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 

	end if
end foreach

foreach	with hold
	select renglon,
	       no_orden,           
	       no_tranrec,       
           no_reclamo,
		   cod_sucursal,
		   periodo,
		   fecha,
		   cod_tipotran
	  into _renglon,
		   _no_orden,    
		   _no_tranrec,
           _no_reclamo,  
		   _cod_sucursal,
		   _periodo,     
		   _fecha,
		   _cod_tipotran       
	  from tmp_trans_wf
	  
	  select numrecla, transaccion, wf_incidente, wf_aprobado, monto, wf_apr_j, wf_apr_j_fh, wf_apr_jt, wf_apr_jt_fh, wf_apr_g, wf_apr_g_fh
	    into _numrecla, _transaccion, _wf_incidente, _wf_aprobado, _monto, _wf_apr_j, _wf_apr_j_fh, _wf_apr_jt, _wf_apr_jt_fh, _wf_apr_g, _wf_apr_g_fh
		from rectrmae
	   where no_tranrec = _no_tranrec;
	   
	  return _renglon,
	  		 _no_orden, 
	  		 _numrecla,
			 _fecha,
	         _transaccion,  
			 _wf_incidente,
			 _wf_aprobado,
			 _monto, _wf_apr_j, _wf_apr_j_fh, _wf_apr_jt, _wf_apr_jt_fh, _wf_apr_g, _wf_apr_g_fh
	  with resume;
	   
end foreach

drop table tmp_trans_wf;
end
end procedure