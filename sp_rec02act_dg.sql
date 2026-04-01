-- Procedimiento que Carga los Reclamos Pendientes en un Periodo Dado
-- 
-- Creado    : 05/08/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 27/06/2002 - Autor: Amado Perez M. 

	-- Agregando el filtro de Agentes

-- Modificado: 21/01/2006 - Autor: Demetrio Hurtado Almanza

   	-- Se cambio la forma en que se obtiene el porcentace de reaseguro de la retencion, antes se hacia 
	-- usando recrcrea, pero como el reaseguro de los reclamos cambio a que sea a nivel de las transacciones
	-- fue necesario realizar este cambio
--execute procedure sp_rec02('001','001','2016-03',"*","*","*","002,020,023;","*")
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec02act;

create procedure "informix".sp_rec02act(
a_compania		char(3), 
a_agencia		char(3), 
a_periodo		char(7),
a_sucursal		char(255) default "*",
a_ajustador	char(255) default "*",
a_grupo     	char(255) default "*",
a_ramo      	char(255) default "*",
a_agente		char(255) default "*"
) returning char(255);

-- variables para filtros

define v_filtros     char(255);
define _tipo         char(1);

-- variable del procedure

define _numrecla     		char(18);
define _no_reclamo   		char(10);
define _no_tranrec   		char(10);
define _no_poliza    		char(10); 
define _periodo      		char(7);
define _cod_agente    	    char(5);
define _cod_grupo    		char(5);
define _ajust_interno		char(3);
define _cod_sucursal 		char(3);
define _cod_coasegur 		char(3);
define _cod_ramo     		char(3);
define _cod_cober_reas	    char(3);
define _cod_cobertura		char(5);

define _monto_total  		dec(16,2);
define _monto_bruto  		dec(16,2);
define _monto_neto   		dec(16,2);
define _monto_cob   		dec(16,2);
define _porc_coas    		dec(16,4);
define _porc_reas    		dec(16,6);
define _no_documento        char(20);

define _fecha         		date;
define _cod_cober_reas_no	char(3);
define _cnt_cober_reas      smallint;
define _existe              smallint;

--set debug file to "sp_rec02.trc ";
--trace on;

set isolation to dirty read;

-- seleccion del codigo de la compania lider
-- y del contrato de retencion

let _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

create temp table tmp_sinis(
		no_reclamo			char(10)  not null,
		no_poliza			char(10)  not null,
		cod_sucursal		char(3)   not null,
		cod_grupo			char(5)   not null,
		cod_ramo			char(3)   not null,
		periodo				char(7)   not null,
		numrecla			char(18) ,
		ultima_fecha		date      not null,
		pagado_total		dec(16,2) not null,
		pagado_bruto		dec(16,2) not null,
		pagado_neto			dec(16,2) not null,
		reserva_total		dec(16,2) not null,
		reserva_bruto		dec(16,2) not null,
		reserva_neto		dec(16,2) not null,
		incurrido_total		dec(16,2) not null,
		incurrido_bruto		dec(16,2) not null,
		incurrido_neto		dec(16,2) not null,
  		ajust_interno		char(3),
		seleccionado		smallint  default 1 not null,
		porc_partic_coas	dec(16,4),
		no_documento        char(20),
		primary key (no_reclamo)) with no log;

create temp table tmp_agente(
no_reclamo		char(10)  not null,
cod_agente		char(5)   not null,
seleccionado	smallint  default 1 not null
) with no log;

set isolation to dirty read;

--- Determinar los reclamos con reserva pendiente

{foreach 
	select no_reclamo,
		   sum(variacion)
	  into _no_reclamo,	
		   _monto_total
	  from rectrmae 
	 where cod_compania	= a_compania
	   and periodo     	= a_periodo 
	   and actualizado  	= 1
	 group by no_reclamo
	having sum(variacion) > 0 }
	
foreach
 select a.no_reclamo,
        sum(a.variacion)
   into _no_reclamo,	
	    _monto_total   
   from rectrmae a, recrcmae b
  where a.cod_compania = a_compania
    and a.periodo      <= a_periodo 
    and a.actualizado  = 1   
    and a.no_reclamo = b.no_reclamo   
    and a.numrecla = b.numrecla
    and b.no_documento = '1819-99900-01'
  group by a.no_reclamo
 --having sum(a.variacion) > 0  

	-- Ultima Fecha de Transaccion
	select max(fecha)
	  into _fecha
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_compania = a_compania
	   and periodo     <= a_periodo
	   and actualizado = 1;

	-- Lectura de la Tablas de Reclamos
	select no_poliza,
		   periodo,
		   numrecla,
  		   ajust_interno,
		   no_documento
	  into _no_poliza,
	  	   _periodo,	
	  	   _numrecla,
		   _ajust_interno,
		   _no_documento
	  from recrcmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;
	
	if _no_poliza is null then
		continue foreach;
	end if
	if _no_documento <> '1819-99900-01' then
		continue foreach;
	end if
    if _numrecla = "00-0000-00000-00" then
	   continue foreach;
	end if;
 
	-- Informacion de Polizas
	select cod_ramo,
	       cod_grupo,
		   cod_sucursal
	  into _cod_ramo,	
	  	   _cod_grupo,
		   _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Informacion de Coseguro 
	select porc_partic_coas 
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	-- Actualizacion del Movimiento
	insert into tmp_sinis(
			pagado_total, 
			pagado_bruto,	
			pagado_neto,
			reserva_total,
			reserva_bruto,
			reserva_neto,
			incurrido_total,	
			incurrido_bruto,
			incurrido_neto,
			no_reclamo,
			no_poliza,
			cod_ramo,
			periodo,	
			numrecla,	
			cod_grupo,
			ultima_fecha,
			cod_sucursal,
			ajust_interno,
			porc_partic_coas,
			no_documento)
	values(	0,	
			0,
			0,
			0,	
			0,
			0,
			0,
			0,
			0,
			_no_reclamo,
			_no_poliza,	
			_cod_ramo,
			_periodo,	
			_numrecla,
			_cod_grupo,
			_fecha,
			_cod_sucursal,
			_ajust_interno,
			_porc_coas,
			_no_documento);

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		insert into tmp_agente(
				no_reclamo,   
				cod_agente,   
				seleccionado)
		values(	_no_reclamo,
				_cod_agente,
				1);
				
	end foreach
	
end foreach

foreach 
 select no_reclamo, 
         porc_partic_coas,
         cod_ramo		 
   into _no_reclamo, 
        _porc_coas,
        _cod_ramo		
   from tmp_sinis 

	-- Variacion de Reserva
	
	foreach 
	 select no_tranrec,		
		    variacion
	   into _no_tranrec,	
		    _monto_total
	   from rectrmae 
	  where no_reclamo		= _no_reclamo
	    and periodo     	<= a_periodo 
	    and actualizado 	= 1
	    and cod_compania	= a_compania
	    and variacion   	<> 0

		let _monto_bruto 	= _monto_total / 100 * _porc_coas;
		let _monto_neto  	= 0;

		foreach
		 select cod_cobertura,
				 variacion
		   into	 _cod_cobertura,
				 _monto_cob
		   from rectrcob
		  where no_tranrec = _no_tranrec
			and variacion  <> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;	

			 
			--Ajuste de Transacción con Distribución de Reaseguro Incorrecta
			select count(*)
			  into _cnt_cober_reas
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_cober_reas is null then
				let _cnt_cober_reas = 0;
			end if

			if _cnt_cober_reas = 0 then
				if _cod_cober_reas = '002' then
					let _cod_cober_reas = '033';
				elif _cod_cober_reas = '031' then
					if _no_tranrec in ('1555383','1555327') then
						let _cod_cober_reas = '002';
					else
						let _cod_cober_reas = '034';
					end if
				elif _cod_cober_reas = '033' then
					let _cod_cober_reas = '002';
				elif _cod_cober_reas = '034' then
					let _cod_cober_reas = '031';
				end if
			end if

			-- Informacion de Reaseguro
			let _porc_reas = 0;
			foreach
			 select	porc_partic_suma
			   into _porc_reas
			   from rectrrea
			  where no_tranrec     = _no_tranrec
				and cod_cober_reas = _cod_cober_reas
				and tipo_contrato  = 1
				exit foreach;
			end foreach
			
			if _porc_reas is null then
				let _porc_reas = 0;
			end if;
			
			let _monto_cob 	= _monto_cob   / 100 * _porc_coas;
			let _monto_cob		= _monto_cob   / 100 * _porc_reas;
			let _monto_neto	= _monto_neto  + _monto_cob;

		end foreach
	
		update tmp_sinis
		   set reserva_total = reserva_total + _monto_total,
			   reserva_bruto = reserva_bruto + _monto_bruto,
			   reserva_neto  = reserva_neto  + _monto_neto
		 where no_reclamo    = _no_reclamo;
		 
	end foreach

	-- Pagos, Salvamentos, Recuperos y Deducibles

	foreach
		select no_tranrec,
			   monto
	      into _no_tranrec,		
	 	       _monto_total
		  from rectrmae
		 where no_reclamo   	= _no_reclamo
		   and periodo      	= a_periodo
		   and actualizado 	= 1
		   and cod_compania	= a_compania
		   and cod_tipotran in (4,5,6,7) 

		let _monto_bruto 	= _monto_total / 100 * _porc_coas;
		let _monto_neto  	= 0;

		foreach
		 select cod_cobertura,
				 monto
		   into	 _cod_cobertura,
				 _monto_cob
		   from rectrcob
		  where no_tranrec = _no_tranrec
			and monto  	<> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			-- Informacion de Reaseguro

			let _porc_reas = 0;

			foreach
			 select	porc_partic_suma
			   into _porc_reas
			   from rectrrea
			  where no_tranrec     = _no_tranrec
				and cod_cober_reas = _cod_cober_reas
				and tipo_contrato  = 1
				exit foreach;
			end foreach
			
			if _porc_reas is null then
				let _porc_reas = 0;
			end if;
			
			let _monto_cob = _monto_cob   / 100 * _porc_coas;
			let _monto_cob = _monto_cob   / 100 * _porc_reas;
			let _monto_neto	= _monto_neto  + _monto_cob;

		end foreach

		-- Actualizacion del Movimiento
		update tmp_sinis
		   set pagado_total = pagado_total + _monto_total,
			   pagado_bruto = pagado_bruto + _monto_bruto,
			   pagado_neto  = pagado_neto  + _monto_neto
		 where no_reclamo   = _no_reclamo;
		 
	end foreach
	
end foreach

-- Actualizacion del Incurrido

update tmp_sinis
   set incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;
 
-- Procesos para Filtros

let v_filtros = "";

if a_sucursal <> "*" then

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  Trim(a_sucursal);
	let _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then	-- Incluir los Registros

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);
	else				-- Excluir estos Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_grupo <> "*" then

	let v_filtros = trim(v_filtros) || " Grupo: " ||  trim(a_grupo);
	let _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in (select codigo from tmp_codigos);

	else		        -- Excluir estos Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: " ||  trim(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- (I) Incluir los Registros

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);

	else		        -- (E) Excluir estos Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_ajustador <> "*" then

	let v_filtros = trim(v_filtros) || " Ajustador: " ||  TRIM(a_ajustador);
	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and ajust_interno not in (select codigo from tmp_codigos);

	else		        -- Excluir estos Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and ajust_interno in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_agente <> "*" then

	let v_filtros = trim(v_filtros) || " Agente: " ||  TRIM(a_agente);

	let _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_agente
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in (select codigo from tmp_codigos);

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_reclamo in (select no_reclamo from tmp_agente where seleccionado = 0);

	else		        -- Excluir estos Registros

		update tmp_agente
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in (select codigo from tmp_codigos);

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_reclamo in (select no_reclamo from tmp_agente where seleccionado = 0);

	end if

	drop table tmp_codigos;
end if

drop table tmp_agente;

return v_filtros;

end procedure;
