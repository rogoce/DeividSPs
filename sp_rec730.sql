-- Preliminar de Ajuste Orden de Compra / Reparacion
-- a una Fecha Dada
-- 
-- Creado    : 19/11/2014 - Autor: Armando Moreno
-- Modificado: 19/11/2014 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec730;
create procedure "informix".sp_rec730(a_compania char(3),a_no_ajuste char(5)) 
returning	char(100),			  
			char(50),			   
			char(100),			  
			char(100),			  
			char(18),			  
			date,				  
			char(50),			  
			char(10),			  
			varchar(50),		  
			varchar(50),		  
			smallint,			  
			varchar(50),		  
			varchar(50),		  
			char(20),			  
			char(10),			  
			date,				  
			char(10),			  
			decimal(16,2),		  
			date,				  
			char(10),
			smallint,
			varchar(255),
			char(5);

define _solicitado_por		varchar(50);
define v_tipoauto			varchar(50);
define v_modelo				varchar(50);		   
define v_no_chasis			varchar(30);		   
define v_proveedor			char(100);			   
define v_asegurado			char(100);			   
define v_reclamante			char(100);			   
define v_compania_nombre	char(50);
define v_marca				char(50);
define _no_motor			char(30);
define v_reclamo			char(18);
define _cod_reclamante		char(10);
define _wf_proveedor		char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_orden			char(10);
define _cod_ajustador		char(3);
define _cod_tipoauto		char(3);
define _tipo_reclamante		char(1);
define _wf_inc_padre		integer;
define _wf_inc_auto			integer;
define _cant_reclamante		smallint;
define v_ano_auto			smallint;
define v_fecha_ajuste		date;

DEFINE _tipo_ajuste         char(1);
DEFINE _cod_proveedor		char(10);
DEFINE _n_proveedor         char(100);
DEFINE _renglon				smallint;
DEFINE _tipo_opc			smallint;
DEFINE _no_tramite			char(10);
DEFINE _n_tipo_ajuste       char(20);
DEFINE _no_factura			char(10);
DEFINE _fecha_factura		date;
DEFINE _monto_factura		decimal(16,2);
define _estado_cta          char(10);
define _fecha_recibido      date;
define _descripcion         varchar(255);

set isolation to dirty read;

-- nombre de la compania
let v_compania_nombre = sp_sis01(a_compania);

	   
--set debug file to "sp_rec730.trc";
--trace on;

-- lectura de ajuste
select cod_proveedor,
       tipo_ajuste,
	   user_added,
	   fecha_ajuste,
	   fecha_recibido,
	   estado_cta
  into _cod_proveedor,
       _tipo_ajuste,
	   _user_added,
	   v_fecha_ajuste,
	   _fecha_recibido,
	   _estado_cta
  from recordam
 where no_ajus_orden = a_no_ajuste;

if _tipo_ajuste = 'C' then
	let _n_tipo_ajuste = 'ORDEN DE COMPRA';
elif _tipo_ajuste = 'A' then
	let _n_tipo_ajuste = 'ALQUILER';
else
	let _n_tipo_ajuste = 'ORDEN DE REPARACION';
end if

select nombre
  into v_proveedor
  from cliclien
 where cod_cliente = _cod_proveedor;

let _monto_factura = 0;

foreach	 
	select no_orden,
		   renglon,
		   tipo_opc,
		   numrecla,
		   no_tramite,
		   no_factura,
		   fecha_factura,
		   monto,
		   descripcion
	  into _no_orden,
		   _renglon,
		   _tipo_opc,
		   v_reclamo,
		   _no_tramite,
		   _no_factura,
		   _fecha_factura,
		   _monto_factura,
		   _descripcion
	  from recordad
	 where no_ajus_orden =  a_no_ajuste
	order by renglon
 	
	select cod_reclamante,
	       cod_asegurado,
		   no_motor
   	  into _cod_reclamante,
           _cod_cliente,
		   _no_motor
      from recrcmae
     where numrecla  	= v_reclamo
       and cod_compania	= a_compania
	   and actualizado	= 1;

	select cod_marca,
		   cod_modelo,
		   no_chasis,
		   ano_auto
	  into _cod_marca,
		   _cod_modelo,
		   v_no_chasis,
		   v_ano_auto
	  from emivehic
	 where no_motor = _no_motor;

	-- lectura de cliente
	select nombre
	  into v_asegurado
 	  from cliclien
	 where cod_cliente = _cod_cliente;

	if v_asegurado is null then
		let v_asegurado = " ";
	end if 

	-- lectura de reclamante
	select nombre
	  into v_reclamante
 	  from cliclien
	 where cod_cliente = _cod_reclamante;


	--lectura del Usuario que Hizo la Orden de Compra
	select descripcion
	  into _solicitado_por
	  from insuser
	 where usuario = _user_added;
	
    -- lectura marca
    select nombre
	  into v_marca
	  from emimarca
	 where cod_marca = _cod_marca;

    select nombre,
	       cod_tipoauto
	  into v_modelo,
	       _cod_tipoauto
	  from emimodel
	 where cod_marca  = _cod_marca
	   and cod_modelo = _cod_modelo;

    select nombre
	  into v_tipoauto
	  from emitiaut
	 where cod_tipoauto = _cod_tipoauto;

	return v_proveedor,      
		   trim(v_marca),		    
	 	   v_asegurado,      
		   v_reclamante,     
		   v_reclamo,        
		   v_fecha_ajuste,	
		   trim(v_compania_nombre),
		   _no_orden,
		   trim(v_modelo),
		   trim(v_no_chasis),
		   v_ano_auto,
		   trim(v_tipoauto),
		   trim(_solicitado_por),
		   _n_tipo_ajuste,
		   _no_tramite,
		   _fecha_factura,
		   _no_factura,
		   _monto_factura,
		   _fecha_recibido,
		   _estado_cta,
		   _tipo_opc,
		   _descripcion,
		   a_no_ajuste
		   with resume;
end foreach
end procedure