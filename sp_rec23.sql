-- Procedimiento Orden de Compra
-- a una Fecha Dada
-- 
-- Creado    : 05/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 05/09/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec23;
--drop table tmp_arreglo;
create procedure "informix".sp_rec23(a_compania char(3), a_agencia char(3), a_orden char(5)) 
returning	char(100),
			char(50),
			char(100),
			char(100),
			char(18),
			char(50),
			date,
			varchar(50),
			char(10),
			char(10),
			varchar(50),
			char(5),
			varchar(50),
			varchar(30),
			smallint,
			varchar(50),
			varchar(50),
			char(30),
			char(10),
			dec(16,2),
			char(10);

define _solicitado_por		varchar(50);
define v_tipoauto			varchar(50);
define v_modelo				varchar(50);
define v_no_chasis			varchar(30);
define v_proveedor			char(100);
define v_asegurado			char(100);
define v_reclamante			char(100);
define v_compania_nombre	char(50);
define v_entregar_a			varchar(50);
define v_ajustador			char(50);
define v_marca				char(50);
define _no_motor			char(30);
define v_reclamo			char(18);
define _cod_reclamante		char(10);
define _cod_proveedor		char(10);
define v_transaccion		char(10);
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
define v_fecha_orden		date;
define v_placa              char(10);
DEFINE _deducible           DEC(16,2);
define _no_cotizacion       char(10);

set isolation to dirty read;

-- nombre de la compania
let v_compania_nombre = sp_sis01(a_compania);

create temp table tmp_arreglo(
		no_reclamo		char(10),
		no_tranrec		char(10),
		no_poliza		char(10),    
		cod_cliente		char(10),  
		cod_reclamante	char(10),   
		cod_ajustador	char(3),
		no_motor		char(30),	
		reclamo			char(18),
		cod_proveedor	char(10),
		fecha_orden		date,
		entregar_a		char(50),
		transaccion		char(10),
		solicitado_por	char(8),
        deducible		dec(16,2),
		no_cotizacion   char(10)
		) with no log;   
		
if a_orden = '54635' then		
	set debug file to "sp_rec23.trc";
	trace on;
end if
-- lectura de orden
foreach	
	select cod_ajustador,
		   no_reclamo,
		   fecha_orden,
		   entregar_a,
		   cod_proveedor,
		   no_orden,
		   no_tranrec,
		   user_added,
		   deducible,
		   no_cotizacion
	  into _cod_ajustador,
		   _no_reclamo,
		   v_fecha_orden,
		   v_entregar_a,
		   _cod_proveedor,
		   _no_orden,
		   _no_tranrec,
		   _user_added,
		   _deducible,
		   _no_cotizacion
	  from recordma
	 where no_orden		= a_orden
	   and actualizado	= 1

 {select no_tranrec
   into _no_tranrec
   from recordam
  where no_orden = _no_orden
    and actualizado = 1;}
 	
   	-- lectura de reclamos
	select no_tramite,	--> en vez de numrecla que salga el no_tramite sabish 17/02/2011
           no_poliza,
		   cod_reclamante,
		   no_motor
   	  into v_reclamo,
           _no_poliza,
		   _cod_reclamante,
		   _no_motor
      from recrcmae
     where no_reclamo	= _no_reclamo
       and cod_compania	= a_compania
	   and actualizado	= 1;

	-- lectura de trancciones
	select transaccion,
	       wf_inc_auto,
		   wf_inc_padre
	  into v_transaccion,
	       _wf_inc_auto,
		   _wf_inc_padre
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	-- lectura de polizas

	select cod_contratante
	  into _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_arreglo(
	no_reclamo,     
	no_tranrec,   
	no_poliza,   
	cod_cliente,	   
	cod_reclamante, 
	cod_ajustador,  
	no_motor,       
	reclamo,        
	cod_proveedor,
	entregar_a,
	fecha_orden,
	transaccion,
	solicitado_por,
	deducible,
	no_cotizacion
	)
	values(
	_no_reclamo,    
	_no_tranrec,   
	_no_poliza,  
	_cod_cliente,	  
	_cod_reclamante,
	_cod_ajustador, 
	_no_motor,
	v_reclamo,      
	_cod_proveedor, 
	v_entregar_a,
	v_fecha_orden,
	v_transaccion,
	_user_added,
	_deducible,
	_no_cotizacion
	);
end foreach;

--recorre la tabla temporal y asigna valores a variables de salida
foreach with hold
	select no_reclamo,   
		   no_tranrec,
		   no_poliza,
		   cod_cliente,
		   cod_reclamante,
		   cod_ajustador,
		   no_motor,
		   reclamo,
		   cod_proveedor,
		   entregar_a,
		   fecha_orden,
		   transaccion,
		   solicitado_por,
		   deducible,
		   no_cotizacion
	  into _no_reclamo,    
		   _no_tranrec,
		   _no_poliza,
		   _cod_cliente,
		   _cod_reclamante,
		   _cod_ajustador,
		   _no_motor,
		   v_reclamo,
		   _cod_proveedor,
		   v_entregar_a,
		   v_fecha_orden,
		   v_transaccion,
		   _user_added,
		   _deducible,
		   _no_cotizacion
	  from tmp_arreglo
	 order by cod_proveedor

	foreach
		select tipo_reclamante
		  into _tipo_reclamante
		  from wf_ordcomp
		 where wf_incidente = _wf_inc_auto 
        exit foreach;
    end foreach

    let _cant_reclamante = 0;

    if _tipo_reclamante is null then
		foreach
			select count(*)
			  into _cant_reclamante
			  from recterce
			 where no_incidente = _wf_inc_padre
		    
	    	if _cant_reclamante = 0 then
			   let _tipo_reclamante = "A";
			else
			   let _tipo_reclamante = "T";
			end if
		end foreach
	end if 

	if _tipo_reclamante = "T" then
		select cod_tercero,
		       no_motor,
			   cod_marca,
			   cod_modelo,
		       ano_auto,
			   placa
	 	  into _cod_reclamante,
		       _no_motor,
			   _cod_marca,
			   _cod_modelo,
		       v_ano_auto,
			   v_placa
	 	  from recterce
	 	 where no_reclamo = _no_reclamo
	 	   and no_incidente = _wf_inc_padre;

		let v_no_chasis = "";
	else
	    select cod_marca,
		       cod_modelo,
			   no_chasis,
			   ano_auto,
			   placa
		  into _cod_marca,
		       _cod_modelo,
			   v_no_chasis,
			   v_ano_auto,
			   v_placa
		  from emivehic
		 where no_motor = _no_motor;
	end if	   

 	let _wf_proveedor = "";

    if v_entregar_a is null or trim(v_entregar_a) = "" then
		let v_entregar_a = "";
    	foreach
			select wf_proveedor
			  into _wf_proveedor
			  from wf_ordcomp
			 where wf_incidente = _wf_inc_auto 
			   and tipo_orden = "R"
            exit foreach;
	    end foreach
		
    	if _wf_proveedor is null or trim(_wf_proveedor) = "" then
			select cod_taller
			  into _wf_proveedor
			  from recrcmae
			 where no_reclamo = _no_reclamo;
			 
	        select nombre
			  into v_entregar_a
			  from cliclien
			 where cod_cliente = _wf_proveedor;
		else
	        select nombre
			  into v_entregar_a
			  from cliclien
			 where cod_cliente = _wf_proveedor;
		
		end if		

    {	if _wf_proveedor is null or trim(_wf_proveedor) = "" then
			let _wf_proveedor = "";
		else
	        select nombre
			  into v_entregar_a
			  from cliclien
			 where cod_cliente = _wf_proveedor;
		end if
		}
    end if	 

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

	-- lectura de proveedor
	select nombre
	  into v_proveedor
 	  from cliclien
	 where cod_cliente = _cod_proveedor;

	--lectura del Usuario que Hizo la Orden de Compra
	select descripcion
	  into _solicitado_por
	  from insuser
	 where usuario = _user_added;
	
    -- lectura de ajustador
	select nombre
	  into v_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

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
	 where cod_marca = _cod_marca
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
		   v_ajustador,		
		   v_fecha_orden,	
		   trim(v_entregar_a),
		   v_transaccion,
		   _no_tranrec,
		   trim(v_compania_nombre),
		   a_orden,
		   trim(v_modelo),
		   trim(v_no_chasis),
		   v_ano_auto,
		   trim(v_tipoauto),
		   trim(_solicitado_por),
		   _no_motor,
		   v_placa,
		   _deducible,
		   _no_cotizacion
		   with resume;
end foreach
drop table tmp_arreglo;
end procedure