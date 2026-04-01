-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

drop procedure sp_che35;

create procedure sp_che35(a_fecha_desde date, a_fecha_hasta date)
--returning smallint;	-- compania

{a_compania      char(3), 
a_sucursal 		 char(3),
a_fecha_desde    date,
a_fecha_hasta    date
) returning smallint;	-- compania
}

define v_nombre_clte		char(100);
define v_nombre_agt			char(50);
define v_nombre_cia			char(50);
define v_no_documento		char(20);
define v_no_licencia		char(10);
define _cod_cliente			char(10);
define v_no_poliza			char(10);
define v_no_recibo			char(10);
define _no_recibo			char(10);
define _no_requis			char(10);
define v_cod_agente			char(5);
define _tipo_agente			char(1);
define _tipo				char(1);
define _comision_adelanto	dec(16,2);
define v_monto_fianza		dec(16,2);
define v_monto_danos		dec(16,2);
define v_monto_vida			dec(16,2);
define v_comision			dec(16,2);
define v_monto				dec(16,2);
define v_prima				dec(16,2);
define v_porc_partic		dec(5,2);
define v_porc_comis			dec(5,2);
define _anticipo_comis		smallint;
define _cnt_aplica			smallint;
define _tipo_pago			smallint;
define v_fecha				date;
define _no_poliza           char(10);
define _fecha_emision       date;
define _no_factura          char(10);
define _return              integer;
define _mensaje             char(20);
define _vfecha              date;
define _no_documento        char(20);


--SET DEBUG FILE TO "sp_che35.trc";
--TRACE ON;
-- Nombre de la Compania
set isolation to dirty read;

--LET  v_nombre_cia = sp_sis01(a_compania); 

{CALL sp_che02(
"001", 
"001",
a_fecha_desde,
a_fecha_hasta,
1
);
--}
let _mensaje = '';
let _return = 0;

delete from chqcomis where fecha_desde = a_fecha_desde;

foreach
	select cod_agente,
		   no_poliza,
		   no_recibo,
		   fecha,
		   monto,
		   prima,
		   porc_partic,
		   porc_comis,
		   comision,
		   nombre,
		   no_documento,
		   monto_vida,
		   monto_danos,
		   monto_fianza,
		   no_licencia
	  into v_cod_agente,
	  	   v_no_poliza,
	  	   v_no_recibo,
	  	   v_fecha,
	  	   v_monto,
	  	   v_prima,
	  	   v_porc_partic,
	  	   v_porc_comis,
	  	   v_comision,
	  	   v_nombre_agt,
	  	   v_no_documento,
	  	   v_monto_vida,
	  	   v_monto_danos,
	  	   v_monto_fianza,
	  	   v_no_licencia 
	  from tmp_agente
	 order by nombre, fecha, no_recibo, no_documento

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = v_cod_agente;

	if _tipo_agente = "O" then
		continue foreach;
	end if

    -- Anticipo de comision -- Ya no hay anticipo de comisión excepto Ivette Bernal
	
	let _anticipo_comis = 0;
	let _cnt_aplica = 0;
 
 -- CASO: 33614 USER: ZULEYKA Ya no habrá más adelanto Amado 22/01/2020
 
 {   if v_cod_agente = "00628" then 
   
		select count(*)
		  into _cnt_aplica
		  from cobadeco
		 where no_documento = v_no_documento
		   and cod_agente	= v_cod_agente;
		
		if _cnt_aplica > 0 or _cnt_aplica is null then 
			if v_no_poliza <> '00000' then
				let _anticipo_comis = 1;
				select comision_adelanto,
					   no_recibo
				  into _comision_adelanto,
					   _no_recibo
				  from cobadeco
				 where cod_agente	= v_cod_agente
				   and no_documento = v_no_documento;

				if v_no_recibo = _no_recibo then
					let v_comision	= _comision_adelanto;
				else
					let v_comision	= 0.00;
				end if

				update tmp_agente
				   set comision		= v_comision
				 where cod_agente	= v_cod_agente
				   and no_poliza	= v_no_poliza
				   and no_recibo	= v_no_recibo 
				   and fecha		= v_fecha;
			end if
		else
			let _cnt_aplica = 0;
			select count(*)
			  into _cnt_aplica
			  from cobadecoh
			 where no_documento = v_no_documento 
			   and fecha >= v_fecha
			   and poliza_cancelada = 1;

			if v_no_documento <> '0213-00946-04' then
				if _cnt_aplica > 0  or _cnt_aplica is null then
					if v_no_poliza <> '00000' then
						let _anticipo_comis = 1;
						select comision_adelanto,
							   no_recibo
						  into _comision_adelanto,
							   _no_recibo
						  from cobadecoh
						 where cod_agente	= v_cod_agente
						   and no_documento = v_no_documento;
						   
						if v_no_recibo = _no_recibo then
							let v_comision			= _comision_adelanto;
						else
							let v_comision			= 0.00;
						end if
						
						update tmp_agente
						   set comision		= v_comision
						 where cod_agente	= v_cod_agente
						   and no_poliza	= v_no_poliza
						   and no_recibo	= v_no_recibo 
						   and fecha		= v_fecha;					
					end if
				end if
			end if		
		end if
	end if
}	
  	insert into chqcomis(
			cod_agente,	
			no_poliza,	
			no_recibo,	
			fecha,		
			monto,       
			prima,       
			porc_partic,	
			porc_comis,	
			comision,	
			nombre,		
			no_documento,
			monto_vida,  
			monto_danos, 
			monto_fianza,
			no_licencia, 
			seleccionado,
			fecha_desde,
			fecha_hasta,
			fecha_genera,
			anticipo_comis)
	values (
			v_cod_agente,
			v_no_poliza,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_no_documento,
			v_monto_vida,  
			v_monto_danos, 
			v_monto_fianza,
			v_no_licencia,
			0,
			a_fecha_desde,
			a_fecha_hasta,
			current,
			_anticipo_comis
			);
			
end foreach

let _vfecha = current;

if _vfecha < '01/02/2016' then
foreach
	select cod_agente
	  into v_cod_agente
	  from tmp_agente
	 group by cod_agente 

	call sp_sis423(v_cod_agente,current,a_fecha_desde,a_fecha_hasta) returning _return, _mensaje;
	
	select nombre,
	       no_licencia
	  into v_nombre_agt,
	       v_no_licencia
	  from agtagent
     where cod_agente = v_cod_agente;	  

	foreach
		select no_documento,
			   fecha_emision
		  into _no_documento,
			   _fecha_emision
		  from chqcomsa
		 where cod_agente     = v_cod_agente
		   and fecha_comision = _vfecha
		   and pagada         = 1
		   
		let v_no_poliza = sp_sis21(_no_documento);
		select no_factura
		  into _no_factura
		  from emipomae
		 where no_poliza = v_no_poliza;
		 
		insert into chqcomis(
				cod_agente,	
				no_poliza,	
				no_recibo,	
				fecha,		
				monto,       
				prima,       
				porc_partic,	
				porc_comis,	
				comision,	
				nombre,		
				no_documento,
				monto_vida,  
				monto_danos, 
				monto_fianza,
				no_licencia, 
				seleccionado,
				fecha_desde,
				fecha_hasta,
				fecha_genera,
				anticipo_comis,
				bono_salud)
		values (
				v_cod_agente,
				v_no_poliza,
				_no_factura,
				_fecha_emision,
				0,
				0,
				0,
				0,
				25,
				v_nombre_agt,
				_no_documento,
				0,  
				0, 
				0,
				v_no_licencia,
				0,
				a_fecha_desde,
				a_fecha_hasta,
				current,
				0,1
				);	

		BEGIN

			ON EXCEPTION IN(-239)

				UPDATE tmp_agente
				   SET comision     = comision + 25
				 WHERE cod_agente   = v_cod_agente
				   AND no_poliza    = v_no_poliza
				   AND no_recibo    = _no_factura
				   AND fecha        = _fecha_emision;

			END EXCEPTION

			INSERT INTO tmp_agente(
			cod_agente,
			no_poliza,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre,
			no_documento,
			monto_vida,
			monto_danos,
			monto_fianza,
			no_licencia
			)
			VALUES(
			v_cod_agente,
			v_no_poliza,
			_no_factura,
			_fecha_emision,
			0,
			0,
			0,
			0,
			25,
			v_nombre_agt,
			_no_documento,
			0,
			0,
			0,
			v_no_licencia
			);
				
		END
		   
	end foreach
end foreach
end if

{
FOREACH
   SELECT no_requis,
          cod_agente
     INTO _no_requis,
		  v_cod_agente
     FROM chqchmae
    WHERE origen_cheque in (2,7)
      AND fecha_captura = '01/06/2006'
      
   UPDATE chqcomis
      SET no_requis = _no_requis
	WHERE fecha_genera = '02/06/2006'
	  AND cod_agente = v_cod_agente;
      	
END FOREACH
--}
--return 0;

end procedure;