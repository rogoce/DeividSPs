--Investigacion Reclamos que el pago a Asegurado sea mayor a lo recuperado.
  
drop procedure sp_leyri15;
create procedure "informix".sp_leyri15()
returning	dec(16,2),
			dec(16,2),
			char(5),
			char(10),
			char(18),
			char(18),
			date,
			char(100),
			char(10),
			char(10),
			char(10),
			char(10),
			char(10);
			
			
DEFINE v_recupero   	  CHAR(5);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_fech_resol       DATE;
DEFINE v_inicio_ges       DATE;
DEFINE v_tercero	      CHAR(100);
DEFINE v_monto_auto       DEC(16,2);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _cod_abogado      CHAR(3);
DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _deducible        DEC(16,2);
DEFINE _pagado_reclamo   DEC(16,2);
DEFINE _monto_pagado_a   DEC(16,2);
DEFINE _monto_rec_a       DEC(16,2);
DEFINE _monto            DEC(16,2);
define _cnt              integer;
define _no_tramite		 char(10);
define _numrecla		 char(18);
define _n_tercero        char(100);

DEFINE _fecha_recupero	 DATE;
DEFINE _monto_tot,_monto_arreglo		 DEC(16,2);
define _reclamo_tercero char(18);
define _transaccion     char(10);
define _tran_rec		char(10);
define _no_tranrec		char(10);
define _no_requis     char(10);
define _no_remesa		char(10);

set isolation to dirty read;

CREATE TEMP TABLE tmp_arreglo(
		no_recupero		 CHAR(5)   NOT NULL,
		no_reclamo       CHAR(10)  NOT NULL,
		reclamo       	 CHAR(18)  NOT NULL,
		pagado_reclamo   DEC(16,2) NOT NULL,
		fecha_recupero   date,
		recuperado       DEC(16,2) default 0,
		tercero          char(100),
		no_tramite       char(10),
		reclamo_tercero  char(18),
		transaccion      char(10),
		transaccion_rec  char(10),
		no_requis        char(10),
		no_remesa        char(10)
		) WITH NO LOG; 

foreach
	SELECT no_recupero,
 		   no_reclamo,
           fecha_resolucion,
		   fecha_envio,
		   nombre_tercero,
		   pagado_reclamo,
		   fecha_recupero,
		   numrecla,
		   reclamo_tercero
  	  INTO v_recupero,
	       _no_reclamo,
		   v_fech_resol,
		   v_inicio_ges,
		   v_tercero,
		   _pagado_reclamo,
		   _fecha_recupero,
		   v_reclamo,
		   _reclamo_tercero
   	  FROM recrecup
  	 WHERE cod_coasegur = '036'	--Ancón
	   AND fecha_recupero >= '01/01/2012'

	let _no_tramite = null;
	select no_tramite
      into _no_tramite
      from recrcmae
     where no_reclamo = _no_reclamo;	  
	   
	let _monto = 0.00;
	let _monto_pagado_a = 0.00;
	let _transaccion = "";
	let _tran_rec = "";	
	let _no_requis = "";
	let _no_remesa = "";
	FOREACH
		select r.monto,r.transaccion,r.no_requis
		  into _monto,_transaccion,_no_requis
		  from rectrmae r, rectrcon c
		 where r.no_tranrec = c.no_tranrec
		   and r.no_reclamo = _no_reclamo
		   and r.actualizado = 1
		   and r.cod_tipotran = '004' --Pago de reclamo
		   and r.cod_tipopago = '003' --Pago a Asegurado
		   and c.cod_concepto = '015' --Pago directo a Aseg.
		   
		if _monto is null then
			let _monto = 0.00;
		end if
		LET _monto_pagado_a = _monto_pagado_a + _monto;
	exit foreach;
	
	END FOREACH
	
	INSERT INTO tmp_arreglo(
	no_recupero,		
	no_reclamo,    
	reclamo,       
	tercero,       
	pagado_reclamo,
	fecha_recupero,
	no_tramite,
	reclamo_tercero,
	transaccion,
	no_requis
	)
	VALUES(
	v_recupero,
	_no_reclamo,    
	v_reclamo,      
	v_tercero,
	_monto_pagado_a,
	_fecha_recupero,
	_no_tramite,
	_reclamo_tercero,
	_transaccion,
	_no_requis
	);
	
	let _monto = 0.00;
	let _monto_rec_a = 0.00;
	FOREACH
		select r.monto,r.transaccion,r.no_tranrec
		  into _monto,_tran_rec,_no_tranrec
		  from rectrmae r
		 where r.no_reclamo = _no_reclamo
		   and r.actualizado = 1
		   and r.cod_tipotran = '006'	--Recupero
		   and r.cod_tipopago = '004'	--Pago a Tercero
		   and r.cod_cliente = '11465'	--Cliente Aseguradora Ancon
		   
		if _monto is null then
			let _monto = 0.00;
		end if
		LET _monto_rec_a = _monto_rec_a + _monto;
		exit foreach;
	END FOREACH
	
	select count(*)
	  into _cnt
	  from tmp_arreglo
	 where no_reclamo = _no_reclamo;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	foreach
		select no_remesa
		  into _no_remesa
		  from cobredet
		 where no_tranrec = _no_tranrec
		exit foreach;
	end foreach
	 
	if _cnt > 0 then
		update tmp_arreglo
		   set recuperado = recuperado + _monto_rec_a,
		       transaccion_rec = _tran_rec,
			   no_remesa       = _no_remesa
		 where no_reclamo = _no_reclamo;  
		  
	end if
end foreach

foreach
	SELECT pagado_reclamo,
 		   recuperado,
		   no_recupero,
		   no_reclamo,
		   reclamo,
		   reclamo_tercero,
		   fecha_recupero,
		   tercero,
		   no_tramite,
		   transaccion,
		   transaccion_rec,
		   no_requis,
		   no_remesa
  	  INTO _monto_pagado_a,
		   _monto_rec_a,
		   v_recupero,
		   _no_reclamo,
		   _numrecla,
		   _reclamo_tercero,
		   _fecha_recupero,
		   _n_tercero,
		   _no_tramite,
		   _transaccion,
		   _tran_rec,
		   _no_requis,
		   _no_remesa
  	  FROM tmp_arreglo
	 where recuperado <> 0 
	  
	if abs(_monto_pagado_a) > abs(_monto_rec_a) then
		return _monto_pagado_a,
			   _monto_rec_a,
			   v_recupero,
			   _no_reclamo,
			   _numrecla,
			   _reclamo_tercero,
			   _fecha_recupero,
			   _n_tercero,
			   _no_tramite,
			   _transaccion,
			   _tran_rec,
			   _no_requis,
			   _no_remesa
			   with resume;
	else
		continue foreach;
	end if
end foreach
end procedure