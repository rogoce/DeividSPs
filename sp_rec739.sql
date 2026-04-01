-- Procedimiento que elimina linea en blanco de la Descripcion de la Transaccion

-- Creado    : 11/05/2004 - Autor: Armando Moreno M.
-- Modificado: 11/05/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

drop PROCEDURE sp_rec739;

CREATE PROCEDURE "informix".sp_rec739()
RETURNING char(20) as reclamo,
          char(10) as codigo_asegurado,
          varchar(100) as asegurado,
		  smallint as edad,
		  char(1) as sexo,
          char(10) as codigo_pagador,
          varchar(100) as pagador,
          char(10) as transaccion,
		  varchar(50) as tipo_pago,
		  varchar(100) as a_nombre_de,
		  char(5) as codigo_cobertura,
		  varchar(50) as cobertura,
		  dec(16,2) as monto,
		  CHAR(10) as codigo_icd,
		  varchar(255) as icd,
		  CHAR(10) as codigo_cpt,
		  varchar(255) as cpt,
		  char(8) as usuario,
		  char(2) as pagado, 
		  char(10) as requisicion, 
		  char(20) as poliza,
		  char(5) as codigo_producto,
		  varchar(50) as producto,
		  char(3) as cod_ramo, 
		  varchar(50) as ramo,
		  char(3) as cod_subramo,
		  varchar(50) as subramo,
		  date as fecha_ocurrencia,
		  date as fecha_tramite,
		  date as fecha_siniestro;
		  
define _no_factura   char(10);
define _cod_tipotran char(3);
define _cod_cpt      char(10);
define _monto        dec(16,2);
define _cant         smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);
define _numrecla     char(20);
define _no_tranrec   char(10);
define _monto2        dec(16,2);
define _user_added   char(8);
define _cod_cliente  char(10);
define _cod_tipopago char(3);
define _nombre       varchar(100);
define _cod_cliente2  char(10);
define _pago          varchar(50);
define _pagado        smallint;
define _requisicion   char(10);
define _pagado_s      char(2);
define _cod_ramo      char(3);
define _ramo          varchar(50);
define _no_poliza     char(10);
define _cod_reclamante char(10);
define _cod_cobertura  char(5);
define _cod_asegurado char(10);
define _no_documento  char(20);
define _cod_producto  char(5);
define _producto      varchar(50);
define _fecha_aniversario date;
define _edad          smallint;
define _sexo          CHAR(1);
define _reclamante    varchar(100);
define _asegurado     varchar(100);
define _cobertura     varchar(50);
define _cpt           varchar(255);
define _no_unidad     char(5);
define _fecha         date;
define _cod_icd       char(10);
define _icd           varchar(255);
define _fecha_siniestro date;
define _fecha_factura date;
define _fecha_tr date;
define _cod_subramo   char(3);
define _subramo       varchar(50);

let _fecha = today;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE pago_dup (
	numrecla    CHAR(20), 
	transaccion CHAR(10), 
	pago        VARCHAR(50), 
	nombre      VARCHAR(100), 
	monto2      DEC(16,2), 
	user_added  CHAR(8), 
	pagado      SMALLINT, 
	requisicion CHAR(10),
	cod_ramo    CHAR(3),
	cod_subramo CHAR(3),
	cod_cobertura char(5),
	cod_reclamante CHAR(10),
	cod_asegurado CHAR(10),
	cod_cpt     CHAR(10),
	no_documento char(20),
	cod_producto char(5),
	cod_icd      CHAR(10),
	fecha_siniestro date,
	fecha_factura date,
	fecha date,
	PRIMARY KEY (transaccion, cod_cobertura));

let _no_factura = null;
let _cant = 0;
	  
  foreach
	select no_tranrec,
	       no_factura,
		   cod_tipotran,
		   cod_cpt,
		   monto,
		   cod_cliente,
		   cod_tipopago,
		   numrecla,
		   transaccion,
		   user_added,
		   pagado,
		   no_requis,
		   no_reclamo,
		   fecha_factura,
		   fecha
	  into _no_tranrec,
	       _no_factura,
		   _cod_tipotran,
		   _cod_cpt,
		   _monto,
		   _cod_cliente,
		   _cod_tipopago,
		   _numrecla,
		   _transaccion,
		   _user_added,
		   _pagado,
		   _requisicion,
		   _no_reclamo,
		   _fecha_factura,
		   _fecha_tr
	  from rectrmae
	 where cod_tipotran = '004'
	   and actualizado = 1
	   and anular_nt is null
	   and periodo >= '2016-01'
	   and periodo <= '2016-12'
	   and monto > 0
	   and numrecla[1,2] in ('02','20','23','18','16')
	 --  and pagado = 1
	 
	 select no_poliza,
	        no_unidad,
			cod_reclamante,
			cod_asegurado,
			cod_icd,
			fecha_siniestro
       into _no_poliza,
	        _no_unidad,
			_cod_reclamante,
			_cod_asegurado,
			_cod_icd,
			_fecha_siniestro
       from recrcmae
      where no_reclamo = _no_reclamo;	   

	 select cod_ramo,
	        cod_subramo,
	        no_documento
	   into _cod_ramo,
	        _cod_subramo,
	        _no_documento
	   from emipomae
	  where no_poliza = _no_poliza;
	   
	 let _cod_producto = null;  
	   
	 select cod_producto
       into _cod_producto
	   from emipouni
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad;
		
	  if _cod_producto is null then
		foreach
		 select cod_producto
		   into _cod_producto
		   from endeduni
		  where no_poliza = _no_poliza
			and no_unidad = _no_unidad
		 order by no_endoso desc
		 exit foreach;
		end foreach
	  end if
	  
		select nombre
		  into _pago
		  from rectipag
		 where cod_tipopago = _cod_tipopago;
		 
		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		foreach
			select cod_cobertura,
			       monto
			  into _cod_cobertura,
			       _monto
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0
			   		   
			 BEGIN
			 ON EXCEPTION IN (-239)
			 END EXCEPTION
			 INSERT INTO pago_dup
			 VALUES 
			 (_numrecla, 
			  _transaccion, 
			  _pago, 
			  _nombre, 
			  _monto, 
			  _user_added, 
			  _pagado, 
			  _requisicion, 
			  _cod_ramo, 
			  _cod_subramo,
			  _cod_cobertura, 
			  _cod_reclamante, 
			  _cod_asegurado, 
			  _cod_cpt, 
			  _no_documento, 
			  _cod_producto,
			  _cod_icd,
			  _fecha_siniestro,
			  _fecha_factura,
			  _fecha_tr
			  );
			 END
			--  return _numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion with resume;
			  --exit foreach;
	    end foreach
	end foreach

foreach with hold
	select 	numrecla, 
	        transaccion, 
	        pago, 
	        nombre, 
	        monto2, 
	        user_added, 
	        pagado, 
	        requisicion,
			cod_ramo,
			cod_subramo,
			cod_cobertura,
			cod_reclamante,
			cod_asegurado,
			cod_cpt,
			no_documento,
			cod_producto,
			cod_icd,
			fecha_siniestro,
			fecha_factura,
			fecha
	  into  _numrecla, 
	        _transaccion, 
			_pago, 
			_nombre, 
			_monto2, 
			_user_added, 
			_pagado, 
			_requisicion,
			_cod_ramo,
			_cod_subramo,
			_cod_cobertura, 
			_cod_reclamante, 
			_cod_asegurado, 
			_cod_cpt, 
			_no_documento, 
			_cod_producto,
			_cod_icd,
			_fecha_siniestro,
			_fecha_factura,
			_fecha_tr
	  from  pago_dup
	 order by cod_ramo, numrecla, transaccion, cod_cobertura
	  
	  select nombre,
	         fecha_aniversario,
	         sexo
	    into _reclamante,
		     _fecha_aniversario,
		     _sexo
		from cliclien
	   where cod_cliente = _cod_reclamante;
	   
	  select nombre
  	    into _asegurado
		from cliclien
	   where cod_cliente = _cod_reclamante;
	   
	  LET _edad = sp_sis78(_fecha_aniversario, _fecha);
	  
	  select nombre
	    into _cobertura
		from prdcober
	   where cod_cobertura = _cod_cobertura;
	   
	  select nombre
	    into _cpt
		from reccpt
	   where cod_cpt = _cod_cpt;
	  
	  select nombre
	    into _ramo
		from prdramo
	   where cod_ramo = _cod_ramo;
	  
	  select nombre
	    into _subramo
		from prdsubra
	   where cod_ramo = _cod_ramo
	     and cod_subramo = _cod_subramo;

	   select nombre
	    into _icd
		from recicd
	   where cod_icd = _cod_icd;
	   
	  if _pagado = 1 then
	     let _pagado_s = "Si";
      else
	     let _pagado_s = "No";
	  end if
	  
	  select nombre
	    into _producto
		from prdprod
	   where cod_producto = _cod_producto;
	  
	  return _numrecla, 
	         _cod_reclamante,
			 _reclamante,
			 _edad,
			 _sexo,
			 _cod_asegurado,
			 _asegurado,
	         _transaccion, 
			 _pago, 
			 _nombre, 
			 _cod_cobertura,
			 _cobertura,
			 _monto2, 
			 _cod_icd,
			 _icd,
			 _cod_cpt,
			 _cpt,
			 _user_added, 
			 _pagado_s, 
			 _requisicion, 
			 _no_documento,
			 _cod_producto,
			 _producto,
			 _cod_ramo, 
			 _ramo,
			 _cod_subramo,
			 _subramo,
			 _fecha_factura,
			 _fecha_tr,
             _fecha_siniestro with resume;

end foreach
--return 0,"";
drop table pago_dup;
END PROCEDURE
