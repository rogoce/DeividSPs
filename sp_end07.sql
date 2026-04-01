-- Procedimiento para actualizar el endoso Ramo Salud Cambio de Producto
-- Creado    : 19/03/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_end07;
CREATE PROCEDURE sp_end07(a_poliza CHAR(10), a_endoso char(5))
			RETURNING   SMALLINT, varchar(20);  -- _error
						

DEFINE _error		        INTEGER;
DEFINE _no_unidad           varchar(5);            
DEFINE _suma_asegurada      DEC(16,2);
DEFINE _prima               DEC(16,2);
DEFINE _prima_emipomae      DEC(16,2);
DEFINE _prima_anual         DEC(16,2);              
DEFINE _prima_neta          DEC(16,2);
DEFINE _descuento           DEC(16,2);
DEFINE _recargo             DEC(16,2);
DEFINE _impuesto            DEC(16,2);
DEFINE _prima_bruta         DEC(16,2);
define _no_documento        varchar(15);
define _cod_contratante     varchar(10);
define _cod_subramo,_cod_subramo_prd      char(3);
define _cod_perpago         char(3);
define _cod_formapag        char(3);
define _cod_grupo           varchar(10);
define _nombre              varchar(30);
define _fecha_aniv          date;
define _direccion           varchar(50);
define _telefono1           varchar(10);
define _telefono2           varchar(10);   
define _celular             varchar(10);
define _email               varchar(30);
define _nombre_agente       varchar(30);
define _user_added          varchar(10);
define _periodo             varchar(7);
define _nombre_producto     varchar(50);
define _cod_producto        varchar(10);
define _deducible           dec(16,2);
define _co_pago             dec(16,2);
define _cod_producto_ant    varchar(10);
define _prima_ant           dec(16,2);
define _periodo_ant         varchar(7);
define _cantidad            smallint;
define a_unidad             varchar(10);  
define _cod_depend          varchar(10);
define _prima_depen         DEC(16,2); 
define _descripcion         varchar(20);
define _error_int           smallint;
define _prima_suscrita      DEC(16,2); 
define _prima_retenida      DEC(16,2);
define _li_meses            integer; 
define _porc_partic_suma    DEC(16,2);
define _porc_partic_prima   DEC(16,2);
define _prima_emifacon      DEC(16,2);
define _end_cobertura       varchar(10);
define _existe              smallint;
define _orden               smallint;
define _cod_tipocalc        char(3);
define _cod_producto_new    varchar(10);
define a_periodo char(7);
define _vigencia_inic, _fecha_periodo, a_fecha_aniv, _fecha_actual date;
define _anio_aniv			char(4);
define _mes_aniv			char(2);
define _dia_aniv			char(2);

BEGIN

	ON EXCEPTION SET _error,_error_int,_descripcion 
		RETURN _error, _descripcion ;         
	END EXCEPTION

SET ISOLATION TO DIRTY READ;
--	SET DEBUG FILE TO "sp_end07.trc";      
--	TRACE ON;  
	
{	select valor_parametro
	  into a_periodo
	  from inspaag
	 where codigo_compania = '001'
	   and codigo_agencia = '001'
	   and aplicacion = 'PRO'
	   and version = '02'
	   and codigo_parametro = 'cambio_producto';
}
	select emi_periodo
	  into a_periodo
	  from parparam
	 where cod_compania = '001';
	   
	let _fecha_actual  = sp_sis26() ;
	--let _fecha_periodo = mdy(a_periodo[6,7], 1, a_periodo[1,4]);
	
	--Primer dia del periodo
	CALL sp_sis36bk(a_periodo) RETURNING _fecha_periodo;
	
--	let _cod_grupo = "00001";
	   	
	SELECT no_documento, 
		   cod_contratante, 
		   cod_subramo, 
		   cod_perpago, 
		   cod_formapag,
		   prima_bruta,
		   vigencia_inic,
		   cod_grupo
	  into _no_documento, 
		   _cod_contratante,
		   _cod_subramo,
		   _cod_perpago, 
		   _cod_formapag,
		   _prima_emipomae,
		   _vigencia_inic,
		   _cod_grupo
	  FROM emipomae
	 WHERE no_poliza = a_poliza;
	 
	if month(_vigencia_inic) <= month(_fecha_periodo) then
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
		let a_fecha_aniv = a_fecha_aniv + 1 units year;
	else
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let a_fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
	end if
	
	LET _anio_aniv = YEAR(a_fecha_aniv);

	IF MONTH(a_fecha_aniv) < 10 THEN
		LET _mes_aniv = '0' || MONTH(a_fecha_aniv);
	ELSE
		LET _mes_aniv = MONTH(a_fecha_aniv);
	END IF

	LET a_periodo = _anio_aniv || '-' || _mes_aniv;
	 
	SELECT nombre, 
		   direccion_1,
		   telefono1, 
		   telefono2,
		   celular,
		   e_mail
	  into _nombre, 
		   _direccion,
		   _telefono1, 
		   _telefono2,
		   _celular,
		   _email
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;
	 
	foreach
		select nombre
		  into _nombre_agente
		  from emipoagt a inner join agtagent b on a.cod_agente = b.cod_agente
		 where no_poliza = a_poliza
		exit foreach;
	end foreach 
	 
	SELECT user_added,
		   periodo,
		   vigencia_inic
	  into _user_added,
		   _periodo,
		   _fecha_aniv
      FROM endedmae
     WHERE no_poliza = a_poliza
       and no_endoso = a_endoso;
	   
	Select cobperpa.meses 
      Into _li_meses
	  from cobperpa
	 Where cobperpa.cod_perpago = _cod_perpago;

	if _li_meses = 0 then
		if _cod_perpago = '008' then
			let _li_meses = 12; 	   	
		else
			let _li_meses = 1;
		end if
	end if
	
	foreach	
		SELECT no_unidad
		  INTO a_unidad
		  FROM endeduni
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso  

		select nombre, 
		       f.cod_producto,
			   m.cod_subramo
		  into _nombre_producto,
		       _cod_producto,
			   _cod_subramo_prd
		  from endeduni f inner join prdprod m  on f.cod_producto = m.cod_producto
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad
		   and no_endoso = a_endoso;
	   
		select max(deducible_local), 
			   max(co_pago)
		  into _deducible,
			   _co_pago
		  from prdcobpd
		 where cod_producto = _cod_producto
		   and forma_pagar = 'C'
	  group by forma_pagar;

		select cod_producto,
			   b.prima, 
			   periodo
		  into _cod_producto_ant,
			   _prima_ant,
			   _periodo_ant
		  from emipouni a inner join emipomae b on a.no_poliza = b.no_poliza
		 where a.no_poliza = a_poliza
		   and a.no_unidad = a_unidad;
		  
		let _suma_asegurada = 0.00;	 
		SELECT	no_unidad,suma_asegurada,prima,prima_neta,descuento,recargo,impuesto,prima_bruta, prima_suscrita, prima_retenida
		  INTO	_no_unidad,_suma_asegurada,_prima,_prima_neta,_descuento,_recargo,_impuesto,_prima_bruta,_prima_suscrita,_prima_retenida
		  FROM	endeduni
		 WHERE  no_poliza = a_poliza
		   and  no_unidad = a_unidad
		   AND  no_endoso = a_endoso;

		UPDATE emipouni
		   SET  cod_producto    = _cod_producto
				{suma_asegurada  = _suma_asegurada,
				prima           = prima 			+ _prima,
				prima_neta      = prima_neta 		+ _prima_neta,
				descuento       = descuento 			+ _descuento,
				recargo         = recargo 			+ _recargo,
				impuesto        = impuesto 			+ _impuesto,
				prima_bruta     = prima_bruta		+ _prima_bruta,
				prima_suscrita  = prima_suscrita 	+ _prima_suscrita,
				prima_retenida  = prima_retenida 	+ _prima_retenida,
				prima_total     = prima_total 		+ _prima,
				prima_asegurado = prima_asegurado 	+ _prima}
		 WHERE no_poliza       = a_poliza
		   AND no_unidad       = _no_unidad;
	end foreach	  
		   
		   
	   
	select count(*)
	  into _cantidad
	  from emicartasal2
	 where no_documento = _no_documento;
	 
	select producto_nuevo
	into _cod_producto_new
	from prdnewpro
	where cod_producto = _cod_producto
	and a_fecha_aniv >= desde
	and a_fecha_aniv < hasta
	and activo = 1;
	
	if _cod_producto_new is not null then
		let _cod_producto = _cod_producto_new;
	end if
	
	if _cantidad = 0 then 
		INSERT INTO emicartasal2 (no_documento,   
								  nombre_cliente,   
								  fecha_aniv,   
								  direccion,   
								  telefono1,   
								  telefono2,   
								  celular,   
								  nombre_agente,   
								  entregado,   		--**
								  fecha_entrega, 	--**  
								  devolucion,  		--**
								  causa_devo,   	--**
								  cambio_direc,  	--** 
								  dir_alternativo,	--**   
								  user_added,   
								  date_added,   
								  por_edad,   
								  cod_subramo,   
								  cod_producto,
								  prima,								  
								  cod_perpago,   
								  cod_formapag,   
								  periodo,   
								  enviado_email,   
								  fecha_email,   
								  emails,   
								  enviado_a,   
								  impreso,   
								  cod_grupo,   
								  deducible,   
								  co_pago,   
								  nombre_plan,   
								  deducible_int,   
								  cod_producto_ant,   
								  prima_ant,   
								  periodo_ant )  
						VALUES ( _no_documento,   
								 _nombre,   
								 a_fecha_aniv,   
								 _direccion,   
								 _telefono1,   
								 _telefono2,   
								 _celular,   
								 _nombre_agente,   
								  '',   
								  '',   
								  '',   
								  '',   
								  '',   
								  '',   
								 _user_added,
								 current,
								 0,   
								 _cod_subramo,   
								 _cod_producto,
								 _prima_emipomae, 								 
								 _cod_perpago,   
								 _cod_formapag,   
								 a_periodo,   
								 0,   
								  '',   
								 _email,   
								 0,   
								 0,   
								 _cod_grupo,   
								 _deducible,   
								 _co_pago,   
								 _nombre_producto,   
								 _deducible,   
								 _cod_producto_ant,   
								 _prima_ant,   
								 _periodo_ant);
	else
		update emicartasal2
		   set nombre_cliente        = _nombre,   
			   fecha_aniv            = a_fecha_aniv,   
			   direccion             = _direccion,   
			   telefono1             = _telefono1,   
			   telefono2             = _telefono2,   
			   celular               = _celular,   
			   nombre_agente         = _nombre_agente,   
			   entregado          	 =  '',   
			   fecha_entrega 	     =  '',   
			   devolucion  		     =  '',   
			   causa_devo   	     =  '',   
			   cambio_direc  	     =  '',   
			   dir_alternativo	     =  '',   
			   user_added            = _user_added,
			   date_added            = current,
			   por_edad              = 0,   
			   cod_subramo           = _cod_subramo,   
			   cod_producto          = _cod_producto,   
			   prima                 = _prima_emipomae,   
			   cod_perpago           = _cod_perpago,   
			   cod_formapag          = _cod_formapag,   
			   periodo               = a_periodo,   
			   enviado_email         = 0,   
			   fecha_email           = '',   
			   emails                = _email,   
			   enviado_a             = 0,   
			   impreso               = 0,   
			   cod_grupo             = _cod_grupo,   
			   deducible             = _deducible,   
			   co_pago               = _co_pago,   
			   nombre_plan           = _nombre_producto, 
			   deducible_int         = _deducible   
		 where no_documento          = _no_documento;
	end if
/*
	foreach
		select cod_cobertura
		  into _end_cobertura
		  from endedcob
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad
		   and no_endoso = a_endoso
		   
		select count(*)
	      into _existe
		  from emipocob
		 where no_poliza 		= a_poliza
		   and no_unidad 		= a_unidad
		   and cod_cobertura 	= _end_cobertura;
			if _existe = 0 then  
				Insert Into emipocob (no_poliza,
									  no_unidad, 
									  cod_cobertura, 
									  orden, 
									  tarifa, 
									  deducible, 
									  limite_1, 
									  limite_2, 
									  prima_anual, 
									  prima, 
									  descuento, 
									  recargo, 
									  prima_neta, 
									  date_added,
									  date_changed, 
									  factor_vigencia, 
									  desc_limite1,
									  desc_limite2)
							   select no_poliza,
									  no_unidad,
									  cod_cobertura,
									  orden,tarifa,
									  deducible,
									  limite_1,
									  limite_2,
									  prima_anual,
									  prima,
									  descuento,
									  recargo,
									  prima_neta,
									  date_added,
									  date_changed,
									  factor_vigencia,
									  desc_limite1,
									  desc_limite2
								from endedcob
							   where no_poliza     = a_poliza
								 and no_unidad     = a_unidad
								 and no_endoso 	   = a_endoso
								 and cod_cobertura = _end_cobertura;
			else
                select prima_anual, 
				       prima_neta, 
					   prima, 
					   cod_cobertura
				  into _prima_anual,
				       _prima_neta,
					   _prima,
					   _end_cobertura
                  from endedcob
				 where no_poliza 	= a_poliza
				   and no_unidad 	= a_unidad
				   and no_endoso 	= a_endoso
				   and prima 		<> 0 
				   and prima_neta 	<> 0 
				   and prima_anual 	<> 0;
				   
				update emipocob
				   set prima_anual 		= _prima_anual, 
				       prima_neta 		= _prima_neta, 
					   prima 			= _prima
				 where no_poliza 		= a_poliza
				   and no_unidad 		= a_unidad
				   and cod_cobertura 	= _end_cobertura;
			end if						 
	end foreach
*/
		 
SELECT prima_bruta,impuesto,prima_neta,descuento,recargo,prima,prima_suscrita,
	   prima_retenida, cod_tipocalc
  INTO _prima_bruta,_impuesto,_prima_neta,_descuento,_recargo,_prima,_prima_suscrita,
	   _prima_retenida, _cod_tipocalc
  FROM endedmae
 WHERE no_poliza   = a_poliza
   AND no_endoso   = a_endoso
   AND actualizado = 0;
   
-- Calculo del recargo    
CALL sp_end18(a_poliza, a_endoso) returning _error, _descripcion;
if _error <> 0 then
	return _error, _descripcion;
end if 
   
if _cod_tipocalc <> '007' then
   UPDATE emipomae
	  SET prima_bruta    = prima_bruta    - _prima_bruta,
		  impuesto       = impuesto       - _impuesto,
		  prima_neta     = prima_neta     - _prima_neta,
		  descuento      = descuento      - _descuento,
		  recargo        = recargo        - _recargo,
		  prima          = prima          - _prima,
		  prima_suscrita = prima_suscrita - _prima_suscrita,
		  prima_retenida = prima_retenida - _prima_retenida
	WHERE no_poliza      = a_poliza;
end if	

UPDATE emipomae
  SET cod_subramo = _cod_subramo_prd
WHERE no_poliza   = a_poliza;

	 
RETURN 0," exito";
END
END PROCEDURE;