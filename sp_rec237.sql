-- Procedure que busca las transacciones de las ordenes de un ajuste para enviarlas a WF												   
-- Creado por: Amado Perez 27/10/2014

drop procedure sp_rec237;

create procedure sp_rec237(a_ajus_orden char(10))
returning integer, char(10), char(10), char(10), char(3), char(7), date, char(3);

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
 	RETURN _error, "", "", null, null, null, null, null;         
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

foreach	with hold
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
	 where no_ajus_orden = a_ajus_orden

    if _no_tranrec_neg is not null and trim(_no_tranrec_neg) <> "" then
	  let _wf_incidente = null;
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente
        into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
             _wf_incidente			 
		from rectrmae
	   where no_tranrec = _no_tranrec_neg;
	   
      if _wf_incidente is null then
		  insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_neg, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 
	  
		  update rectrmae
			 set wf_aprobado = 3,
				 wf_apr_js = null,
				 wf_apr_js_fh = null,
				 wf_apr_j = null,
				 wf_apr_j_fh = null,
				 wf_apr_jt = null,
				 wf_apr_jt_fh = null,
				 wf_apr_g = null,
				 wf_apr_g_fh = null
		   where no_tranrec = _no_tranrec_neg;
	  end if

	end if

    if _no_tranrec_pos is not null and trim(_no_tranrec_pos) <> "" then
	  let _wf_incidente = null;
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente
        into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
             _wf_incidente			 
		from rectrmae
	   where no_tranrec = _no_tranrec_pos;

       if _wf_incidente is null then
		 insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_pos, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 

		  update rectrmae
			 set wf_aprobado = 3,
				 wf_apr_js = null,
				 wf_apr_js_fh = null,
				 wf_apr_j = null,
				 wf_apr_j_fh = null,
				 wf_apr_jt = null,
				 wf_apr_jt_fh = null,
				 wf_apr_g = null,
				 wf_apr_g_fh = null
		   where no_tranrec = _no_tranrec_pos;
	  end if
	end if

    if _no_tranrec_pre is not null and trim(_no_tranrec_pre) <> "" then
	  let _wf_incidente = null;
	  select no_reclamo,
			 cod_sucursal,
			 periodo,
			 fecha,
			 cod_tipotran,
			 wf_incidente
        into _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran,
             _wf_incidente			 
		from rectrmae
	   where no_tranrec = _no_tranrec_pre;

       if _wf_incidente is null then
		  insert into tmp_trans_wf
		  values (_renglon, _no_orden, _no_tranrec_pre, _no_reclamo, _cod_sucursal, _periodo, _fecha, _cod_tipotran); 

		  update rectrmae
			 set wf_aprobado = 3,
				 wf_apr_js = null,
				 wf_apr_js_fh = null,
				 wf_apr_j = null,
				 wf_apr_j_fh = null,
				 wf_apr_jt = null,
				 wf_apr_jt_fh = null,
				 wf_apr_g = null,
				 wf_apr_g_fh = null
		   where no_tranrec = _no_tranrec_pre;
	  end if
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

	  return _renglon,
	  		 _no_orden, 
	  		 _no_tranrec,
	         _no_reclamo,  
			 _cod_sucursal,
			 _periodo,     
			 _fecha,
			 _cod_tipotran       
	  with resume;
	   
end foreach

drop table tmp_trans_wf;
end
end procedure