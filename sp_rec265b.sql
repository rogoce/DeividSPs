-- Reporte de Siniestros Pagados
-- Creado    : 19/04/2016 - Autor: Román Gordón

drop procedure sp_rec265b;
create procedure "informix".sp_rec265b(
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_contrato	char(255) default "*",
a_ramo		char(255) default "*",
a_subramo	char(255) default "*")
returning	char(20)	as Poliza,          --2
			date        as Fecha_Suscripcion,
			date		as Vigencia_Inic,	--31
			date		as Vig_Final,		--32
			char(50)	as Ramo,            --9
			char(18)	as NumRecla,		--1
			char(100)	as Cliente,         --3
			dec(16,2)	as Suma_Asegurada,	--30
			date		as Fecha_Siniestro, --4
			char(10)	as Transaccion,     --5
			char(50)	as Contrato,	    --10
			char(15)	as Serie_Char,		--13
			char(30)	as Cobertura_Reaseguro,		--33
			dec(9,6)	as Porc_Retencion,    --35
			dec(16,2)	as Pagado_Bruto,    --6
			dec(16,2)	as Pagado_Neto,     --14
			dec(16,2)	as Retencion,		--21
			dec(16,2)	as Retencion_Casco,	--34
			dec(16,2)	as Pagado_Cedido,	--23
			dec(16,2)	as Cuota_Parte,		--17
			dec(16,2)	as Excedente,		--18
			dec(16,2)	as Facultativo,		--22
			dec(16,2)	as fac_car_1,		--27
			dec(16,2)	as fac_car_2,		--28
			dec(16,2)	as fac_car_3,		--29
			char(255)	as Filtros,			--12
			char(7)		as Periodo,
			char(50)	as Compania,
			varchar(100) as Beneficiario_Pago,
			varchar(255) as Patologia,
			varchar(50) as Tipo_Servicio;	    --11

define v_filtros          char(255);
define v_cliente_nombre   char(100);    
define v_contrato_nombre  char(50);     
define v_compania_nombre  char(50);     
define v_ramo_nombre      char(50);     
define v_doc_poliza       char(20);     
define v_doc_reclamo      char(18);     
define v_transaccion      char(10);     
define _no_reclamo        char(10);     
define _no_poliza         char(10);     
define _cod_sucursal      char(3);      
define _cod_subramo       char(3);
define _cod_ramo          char(3);      
define _cod_contrato      char(5);     
define _cod_cliente,_no_tranrec       char(10);     
define _tipo              char(1);
define v_fecha_siniestro  date;         
define v_pagado_cedido    dec(16,2);
define v_reserva_cedido   dec(16,2);
define v_incurrido_cedido dec(16,2);

define _periodo           char(7);      
define _tipo_contrato     smallint;
define _porc_reas			dec;
define _porc_coas			dec;
define _porc_partic_prima	dec;
define _pagado_bruto      dec(16,2);
define _reserva_bruto     dec(16,2);
define _incurrido_bruto   dec(16,2);
define _pagado_neto       dec(16,2);
define _reserva_neto      dec(16,2);
define _incurrido_neto    dec(16,2);
define _serie 			  smallint;
define _serie2 			  smallint;
define _pag_ret           dec(16,2);
define _pag_fac           dec(16,2);
define _pag_cont          dec(16,2);
define _res_ret           dec(16,2);
define _res_fac           dec(16,2);
define _res_cont,_reserva_total          dec(16,2);

define v_suma_pag         dec(16,2);
define v_suma_res         dec(16,2);

define _cp_pag            dec(16,2);
define _exc_pag           dec(16,2);
define _cp_res            dec(16,2);
define _exc_res           dec(16,2);
define _exc_ret           dec(16,2);
define _exc_fac           dec(16,2);

define _pag_5,_monto_bruto             dec(16,2);
define _pag_7             dec(16,2);
define _res_5             dec(16,2);
define _res_7             dec(16,2);
define _fac_car_1 	      dec(16,2);
define _fac_car_2 	      dec(16,2);
define _fac_car_3 	      dec(16,2);
define _cod_cobertura     char(5);
define _n_cober           char(30);

define _dt_siniestro      date;
define _serie1 			  smallint;
define _si_hay            smallint;
define _suma_as           dec(16,2);
define _vig_ini			  date;
define _vig_fin			  date;
define _facilidad_car     smallint;
define _cnt3			  smallint;
define _serie_char        char(15);
define _serie_c           char(4);
define _pag_ret_casco,_monto_total     dec(16,2);
define _cod_cober_reas    char(3);
define _transaccion       char(10);
define _cnt_existe		  smallint;
define _no_unidad         char(5);
define _cant              integer;
define _vigencia_inic		date;
define v_nombre_tr        varchar(100);
define _cod_icd           char(10);
define v_icd              varchar(255);
define _cod_concepto      char(3);
define v_concepto         varchar(50);
define _fecha_suscripcion date;

-- nombre de la compania
let  v_compania_nombre = sp_sis01('001');

-- cargar el incurrido
--drop table tmp_sinis;

let v_filtros = sp_rec704('001','001', a_periodo1,a_periodo2,'*','*', a_ramo,'*','*','*','*',a_subramo); 


-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

-- Tabla Temporal para los Contratos
create temp table tmp_contrato1(
periodo			char(7),
no_poliza		char(10),
cod_sucursal	char(3)   not null,
cod_ramo		char(3),
cod_subramo		char(3),
numrecla		char(18),
no_reclamo		char(10),
transaccion		char(10),
no_tranrec		char(10),
cod_contrato	char(5),
cod_cobertura	char(5),
cod_cober_reas	char(3),
serie			smallint,
serie_char		char(15),
porc_partic_ret	dec(9,6),
pagado_bruto	dec(16,2) not null,
pagado_neto		dec(16,2) not null,
ret_pag			dec(16,2),
ret_casco		dec(16,2),
cont_pag		dec(16,2),
cp_pag			dec(16,2),
exc_pag			dec(16,2),
fac_pag			dec(16,2),
fac_car_1		dec(16,2),
fac_car_2		dec(16,2),
fac_car_3		dec(16,2),
seleccionado	smallint  default 1 not null,
primary key (no_tranrec, cod_cober_reas)) with no log;

create index xie01_tmp_contrato1 on tmp_contrato1(cod_contrato);
create index xie02_tmp_contrato1 on tmp_contrato1(cod_ramo);
create index xie03_tmp_contrato1 on tmp_contrato1(no_poliza);
create index xie04_tmp_contrato1 on tmp_contrato1(no_reclamo);
create index xie05_tmp_contrato1 on tmp_contrato1(cod_subramo);

--set debug file to 'sp_rec265.trc';
--trace on;

set isolation to dirty read;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   cod_subramo,
		   sum(pagado_bruto),
		   sum(pagado_neto)	   
	  into _no_reclamo, 		
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _cod_subramo,
		   _pagado_bruto,
		   _pagado_neto
	  from tmp_sinis 
	 where seleccionado = 1
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
	 order by cod_ramo,numrecla

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;
	end if
	
	let v_fecha_siniestro = current;

   	if _pagado_bruto is null  then
		let _pagado_bruto = 0;
	end if

	if _pagado_neto is null  then
		let _pagado_neto = 0;
	end if

	if _pagado_neto = 0 and _pagado_bruto = 0 then
		--continue foreach;
	end if


	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	let _cod_contrato = null;
	
   	foreach
		select a.transaccion,
			   a.periodo,
			   --a.monto,
			   a.variacion,
			   a.no_tranrec
		  into _transaccion,
			   _periodo,
			   --_monto_total,
			   _reserva_total,
			   _no_tranrec
		  from rectrmae a,rectitra b
		 where a.no_reclamo = _no_reclamo
		   and a.actualizado = 1
		   and a.cod_tipotran = b.cod_tipotran
		   and b.tipo_transaccion in (4,5,6,7)
		   and a.periodo >= a_periodo1 
		   and a.periodo <= a_periodo2
		   and a.monto <> 0

		foreach
			select monto,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			select porc_partic_coas
			  into _porc_coas
			  from reccoas
			 where no_reclamo   = _no_reclamo
			   and cod_coasegur = '036';

			if _porc_coas is null then
				let _porc_coas = 0;
			end if

			let _monto_bruto = 0;
			let _monto_bruto = _monto_total  / 100 * _porc_coas;

			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_existe is null or _cnt_existe = 0 then

				RETURN '',--2
					   '01/01/1900',--31
					   '01/01/1900',--31
					   '01/01/1900',--32
					   '',--9
					   '1',--1
					   '',--3
					   0.00,--30
					   '01/01/1900',--4
					   '',--5
					   '',--10
					   '',--13
					   '',--33
					   0.00,--35
					   0.00,--6
					   0.00,--14
					   0.00,--21
					   0.00,--34
					   0.00,--23
					   0.00,--17
					   0.00,--18
					   0.00,--22
					   0.00,--27
					   0.00,--28
					   0.00,--29
					   "No hay Distribucion de Reaseguro para la Transaccion: " || _no_tranrec || " " || _cod_cober_reas,
					   '',--11
					   '',--11
					   '',--11
					   '',--11
					   '';--11
					   
			end if

			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

				let _pag_ret 	= 0;
				let _pag_fac 	= 0;
				let _pag_cont 	= 0;
				let v_suma_pag 	= 0;
				let v_suma_res 	= 0;
				let _cp_pag 	= 0;
				let _exc_pag 	= 0;
				let _pag_5 		= 0;
				let _res_5 		= 0;
				let _pag_7 		= 0;
				let _res_7 		= 0;
				let _fac_car_1  = 0;
				let _fac_car_2  = 0;
				let _fac_car_3  = 0;
				let _facilidad_car = 0;
				let _exc_ret    = 0;
				let _exc_fac    = 0;
				let _pag_ret_casco = 0;


				select tipo_contrato,
					   serie,
					   facilidad_car
				  into _tipo_contrato,
					   _serie,
					   _facilidad_car
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _porc_reas is null then
					let _porc_reas = 0;
				end if

				let v_pagado_cedido = _monto_bruto * _porc_reas / 100;
				
				let _serie_char = "";
				let _serie_c    = "";
				let _serie_c    = _serie;
				let _serie_char = _serie_c;
				
				if _cnt3 > 0 and _serie >= 2011 then
					let _serie_char = _serie_c || ' INUNDACION';
				end if

				if _tipo_contrato = 1 then
					let _porc_partic_prima = _porc_reas;

					if (_cod_ramo = '002' and _cod_cober_reas = '031') or  (_cod_ramo = '023' and _cod_cober_reas = '034') then
						let _pag_ret_casco = _pag_ret_casco + v_pagado_cedido;
					else
						let _pag_ret = _pag_ret + v_pagado_cedido;		   
					end if
				elif _tipo_contrato = 3 then
					let _pag_fac = _pag_fac + v_pagado_cedido;
				else
					let _pag_cont = _pag_cont + v_pagado_cedido;

					if _tipo_contrato = 5 then
						let _pag_5 = _pag_5 + v_pagado_cedido;
					end if
					if _tipo_contrato = 7 then
						if _facilidad_car = 1 then
						else
							let _pag_7 = _pag_7 + v_pagado_cedido;
						end if
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				if _facilidad_car = 1 then

				   let _fac_car_1 = _fac_car_1 + v_pagado_cedido;--_pag_ret + _pag_fac + _pag_cont;	  -- pago
				   let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos

				   let _cp_pag   = 0;
				   let _exc_pag  = 0;
				   --let _pag_ret  = 0; 
				   let _pag_fac  = 0;
				   let _pag_cont = 0;
				   let _pag_ret_casco = 0;
				end if
				
				let _pagado_neto = _pag_ret + _pag_ret_casco;

				if _cod_contrato is null then
				   continue foreach;
				end if

				begin
				on exception in(-239)
					update tmp_contrato1
					   set cp_pag = cp_pag + _pag_5,
						   exc_pag = exc_pag + _pag_7,
						   ret_pag = ret_pag + _pag_ret,
						   fac_pag = fac_pag + _pag_fac,
						   cont_pag = cont_pag + _pag_cont,
						   fac_car_1 = fac_car_1 + _fac_car_1,
						   fac_car_2 = fac_car_2 + _fac_car_2,
						   fac_car_3 = fac_car_3 + _fac_car_3,
						   ret_casco = ret_casco + _pag_ret_casco,
						   pagado_neto = pagado_neto + _pagado_neto
					 where no_tranrec = _no_tranrec
					   and cod_cober_reas = _cod_cober_reas;
				end exception

				insert into tmp_contrato1(
						periodo,
						no_poliza,
						cod_sucursal,
						cod_ramo,
						cod_subramo,
						numrecla,
						no_reclamo,
						transaccion,
						no_tranrec,
						cod_contrato,
						cod_cobertura,
						cod_cober_reas,
						serie,
						serie_char,
						pagado_bruto,
						pagado_neto,
						ret_pag,
						ret_casco,
						cont_pag,
						cp_pag,
						exc_pag,
						fac_pag,
						fac_car_1,
						fac_car_2,
						fac_car_3)
				values(	_periodo,
						_no_poliza,
						_cod_sucursal,
						_cod_ramo,
						_cod_subramo,
						v_doc_reclamo,            
						_no_reclamo,
						'',
						_no_tranrec,
						_cod_contrato,
						_cod_cobertura,
						_cod_cober_reas,
						_serie,
						_serie_char,
						_pagado_bruto,        
						_pagado_neto,        
						_pag_ret,
						_pag_ret_casco,
						_pag_cont,
						_pag_5,
						_pag_7,
						_pag_fac,
						_fac_car_1,
						_fac_car_2,
						_fac_car_3);
				end
			end foreach	 --rectrrea
			
			select porc_partic_prima
			  into _porc_partic_prima
			  from rectrrea r, reacomae c
			 where c.cod_contrato = r.cod_contrato
			   and no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas
			   and c.tipo_contrato = 1;

			update tmp_contrato1
			   set porc_partic_ret = _porc_partic_prima
			 where no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;
		end foreach	 --rectrcob		
	end foreach	 --rectrmae
end foreach		 --tmp_sinis

-- Procesos para Filtros
let v_filtros = "";

if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: " ||  trim(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

let _pag_ret_casco = 0;

FOREACH
	SELECT no_reclamo,          
		   transaccion,			
		   no_poliza,           
		   cod_ramo,            
		   periodo,             
		   numrecla,            
		   pagado_bruto,        
		   serie_char,			
		   pagado_neto,        	
		   no_tranrec,
		   cod_cober_reas,
		   porc_partic_ret,
		   cp_pag,		
		   exc_pag,		
		   ret_pag,		
		   fac_pag,		
		   cont_pag,	
		   fac_car_1, 	
		   fac_car_2,	
		   fac_car_3,	
		   ret_casco	
	  INTO _no_reclamo,			
		   v_transaccion,       
		   _no_poliza,          
		   _cod_ramo,           
		   _periodo,            
		   v_doc_reclamo,       
		   v_pagado_cedido,     
		   _serie_char,         
		   _pagado_neto,        
		   _no_tranrec,
		   _cod_cober_reas,
		   _porc_partic_prima,
		   _cp_pag,             
		   _exc_pag,            
		   _pag_ret,            
		   _pag_fac,            
		   _pag_cont,           
		   _fac_car_1,          
		   _fac_car_2,          
		   _fac_car_3,          
		   _pag_ret_casco		
	  FROM tmp_contrato1        
	 WHERE seleccionado = 1
	
	let _cod_contrato = '';
	let v_contrato_nombre = ''; 

	 --let _pag_ret  = 0;
	let _pag_cont = _cp_pag + _exc_pag;

	select transaccion, 
	       cod_cliente
	  into v_transaccion, 
	       _cod_cliente
	  from rectrmae
	 where no_tranrec = _no_tranrec;
	 
	select nombre
	  into v_nombre_tr
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _cod_icd = null;
	let v_icd = null;	 
	 
	select fecha_siniestro,
		   no_unidad,
		   cod_icd
	  into v_fecha_siniestro,
		   _no_unidad,
		   _cod_icd
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select nombre
      into v_icd
      from recicd
	 where cod_icd = _cod_icd;
	 
	let _cod_concepto = null;
	let v_concepto = null;	 

    foreach
		select cod_concepto
		  into _cod_concepto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		 
		exit foreach;	
    end foreach	

	select nombre
	  into v_concepto
	  from recconce
	 where cod_concepto = _cod_concepto;
	
	select nombre
	  into _n_cober
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;
	
	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _fecha_suscripcion
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre 
	  into v_cliente_nombre	
	  from cliclien 
	 where cod_cliente = _cod_cliente;

    select count(*)
	  into _cant
	  from emipouni
	 where no_poliza = _no_poliza;

	 let v_pagado_cedido = 0;
	 let v_pagado_cedido = _pag_cont + _pag_ret + _pag_ret_casco + _pag_fac + _fac_car_1;
	 
	return	v_doc_poliza,		  --2
	       _fecha_suscripcion,
		   _vig_ini,			--31
		   _vig_fin,			--32
		   v_ramo_nombre,		  --9
			v_doc_reclamo,         --1				
	 	   v_cliente_nombre, 	  --3
		   _suma_as,			--30
	 	   v_fecha_siniestro, 	  --4
		   v_transaccion,		  --5
		   v_contrato_nombre,	  --10
		   _serie_char,			  --13
		   _n_cober,			--33
		   _porc_partic_prima,
		   v_pagado_cedido,		  --6
		   _pagado_neto,          --14
	       _pag_ret,			  --21
		   _pag_ret_casco,		--34
		   _pag_cont,			  --23
		   _cp_pag,				  --17
		   _exc_pag,			  --18
		   _pag_fac,			  --22
		   _fac_car_1,			  --27
		   _fac_car_1,			  --28
		   _fac_car_3,			  --29
		   v_filtros,			  --12
		   _periodo,			  --35
		   v_compania_nombre,	  --11
		   v_nombre_tr,           --12
		   v_icd,                 --13
		   v_concepto             --14
		   with resume;
end foreach

drop table if exists tmp_sinis;
drop table if exists tmp_contrato1;
end procedure;