
-- Procedimiento que trae las polizas para el cte. seleccionado.

-- Creado		: 7/04/2003	- Autor: Armando Moreno M.
-- Modificado	: 26/10/2010	- Autor: Roman Gordon C.
-- Modificado	: 21/06/2011	- Autor: Roman Gordon C.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob103bk;

create procedure sp_cob103bk(
a_compania 	   char(3),
a_agencia      char(3),
a_cod_cliente  char(10),
a_dia          int,
a_cod_campana  char(10)
)
returning char(20),  --1  _no_documento 
       	  date,		 --2  vig ini		  
       	  date,		 --3  vig fin		  
	      char(3),	 --4  cod_ramo	  
	      smallint,  --5  estatus poliza
	      char(7),	 --6  periodo		  
	      char(3),	 --7  cod subramo	  
	      char(1),	 --8  gestion		  
		  char(50),  --9  ramo nombre	  
		  char(50),	 --10 subramo nombre
		  dec(16,2), --11 apagar		  
		  dec(16,2), --12 saldo		  
		  dec(16,2), --13 exigible	  
		  dec(16,2), --14 corriente 	  
		  dec(16,2), --15 monto30		  
		  dec(16,2), --16 monto60		  
		  dec(16,2), --17 monto90		  
		  char(10),	 --18 no_poliza	  
		  dec(16,2), --19 por vencer	  
		  char(100), --20 asegurado	  
		  smallint,  --21 seleccionar	  
		  char(50),	 --22 acreedor	  
  		  dec(16,2), --23 prima orig	  
		  char(50),  --24 agente		  
		  dec(16,2), --25 exigible2	  
		  integer,   --26 ramosis		  
		  char(50),	 --27 no_renovacion 
		  char(10),  --28 cod_campana	  
		  smallint,  --29 selector de gestiones
		  char(3),	 --30 codigo de formapago 
		  char(50),	 --31 nombre Forma de Pago
		  smallint,	 --saber si la póliza es facultativa
		  char(5),	 --cod_grupo
		  char(50),	 --nombre del grupo
		  date;		 --fecha_cubierto




define v_exigible		dec(16,2);
define v_corriente		dec(16,2);
define v_monto_30		dec(16,2);
define v_monto_60		dec(16,2);
define v_monto_90		dec(16,2);
define v_apagar			dec(16,2);
define v_saldo			dec(16,2);
define v_por_vencer		dec(16,2);
define _prima_orig		dec(16,2);
define _porcentaje      dec(16,2);
define _asegurado       char(100);
define _n_acreedor		char(50);
define _nn_acree        char(50);
define _no_renov		char(50);
define _nombre_acreedor	char(50);
define _nombre_agente	char(50);
define _subramo_nom		char(50);
define _ramo_nom		char(50);
define _nom_formapag	char(50);
define _no_documento    char(20);
define _cod_contratante	char(10);
define _no_pol_rec		char(10);
define _no_reclamo		char(10);
define _cod_campana		char(10);
define _no_poliza		char(10);
define _periodo			char(7);
define _peri			char(7);
define _cod_acreedor    char(5);
define _no_unidad		char(5); 
define _cod_agente		char(5);
define _ano_char		char(4);
define _cod_ramo		char(3);
define _cod_formapag	char(3);
define _cod_subramo	    char(3);
define _cod_no_renov	char(3);
define _mes_char        char(2);
define _gestion			char(1);
--define _tipo_mov		char(1);
define _cade            char(1);
define _leasing         smallint; 
define _consulta		smallint;
define _estatus_poliza  smallint;
define _ramo_sis		smallint;
define _seleccionar 	smallint;
define _nn              integer;
define _vigencia_inic 	date;
define _vigencia_final 	date;
define _fecha_suspension 	date;
define _sel_gestion,li_fac		smallint;
define _cod_grupo       char(5);
define _n_grupo 		char(50);


set isolation to dirty read;

--Armar varibale que contiene el periodo(aaaa-mm)
if  month(today) < 10 then
	let _mes_char = '0'||month(today);
else
	let _mes_char = month(today);
end if

let _ano_char		= year(today);
let _periodo		= _ano_char || "-" || _mes_char;
let _prima_orig		= 0;
let v_apagar		= 0.00;
let v_por_vencer	= 0;
let v_exigible		= 0;
let v_corriente		= 0;
let v_monto_30		= 0;
let v_monto_60		= 0;
let v_monto_90		= 0;
let v_saldo			= 0;
let _seleccionar 	= 0;
let _cod_campana 	= '00000';
let _n_grupo        = '';

--let _no_poliza = "";
--let _nombre_agente = "";
--let _nombre_acreedor = "";


{select count(*)
  into _consulta
  from cascliente
 where cod_cliente = a_cod_cliente;}

--if _consulta = 0 then
	foreach						-- Se consulto una poliza por el boton por Llamada y no esta en ninguna camapaña
		select distinct no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = a_cod_cliente

		let _sel_gestion = 0;

		foreach
			select cod_campana,
				   a_pagar
			  into _cod_campana,
				   v_apagar
			  from caspoliza
			 where no_documento = _no_documento
			if _cod_campana = a_cod_campana then
				let _sel_gestion = 1;
				exit foreach;	
			end if
		end foreach;

		select fecha_suspension
		  into _fecha_suspension
		  from emipoliza
		 where no_documento = _no_documento;
			
	   --	if _tipo_mov <> "R" then
		let _no_poliza = sp_sis21(_no_documento); --trae ult. vigencia de la poliza.
		let li_fac = sp_sis439(_no_poliza);
		
		select vigencia_inic,
			   vigencia_final,
			   cod_ramo,
			   estatus_poliza,
			   periodo,
			   cod_subramo,
			   gestion,
			   cod_contratante,
			   prima_bruta,
			   leasing,
			   cod_no_renov,
			   cod_formapag,
			   cod_grupo
		  into _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _estatus_poliza,
			   _peri,
			   _cod_subramo,
			   _gestion,
			   _cod_contratante,
			   _prima_orig,
			   _leasing,
			   _cod_no_renov,
			   _cod_formapag,
			   _cod_grupo
		  from emipomae
		 where no_poliza = _no_poliza;

		-- Selecciona el Primer Acreedor de la Poliza
		let _nombre_acreedor = '... SIN ACREEDOR ...';
		let _cod_acreedor    = '';
		let _no_renov = '';        

		select nombre
		  into _no_renov
		  from eminoren
		 where cod_no_renov = _cod_no_renov;
		 
		let _n_grupo = "";
		select nombre
		  into _n_grupo
		  from cligrupo
		 where cod_grupo = _cod_grupo;
		
		if _no_renov is null then
			let _no_renov = '';
		end if

		let _n_acreedor = ''; 		

		select count(distinct n.nombre)
		  into _nn
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza;

		if _nn > 1 then
			let _cade = ", ";
		else
			let _cade = "";
		end if

		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if


		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if

		if _n_acreedor is null or trim(_n_acreedor) = "" then
			let _n_acreedor = '... SIN ACREEDOR ...';
		end if

		if _leasing = 1 then   -- Cuando la poliza es leasing el acreedor se busca en la unidad Caso 06731
			
				select count(distinct n.nombre)
				  into _nn
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza;

			if _nn > 1 then
				if _n_acreedor = '... SIN ACREEDOR ...' then
					let _n_acreedor = '';
				end if
				
				let _cade = ", ";
			else
				let _cade = "";
			end if

			foreach
				select distinct n.nombre
				  into _nn_acree
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza

				let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

			end foreach

			if _nn > 1 then
			   let _n_acreedor[1,1] = "";
			end if
		end if


		let _cod_agente = null;

		foreach 
			 select	cod_agente,
					porc_partic_agt
			   into	_cod_agente,
					_porcentaje
			   from emipoagt
			  where	no_poliza = _no_poliza
			  order by porc_partic_agt desc

				exit foreach;
		end foreach

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		if _gestion is null then
			let _gestion = "p";
		end if

		select nombre,
			   ramo_sis
		  into _ramo_nom,
			   _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select nombre
		  into _subramo_nom
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		select nombre
		  into _nom_formapag
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		call sp_cob33(
			 a_compania,
			 a_agencia,
			 _no_documento,
			 _periodo,
			 today
			 ) returning v_por_vencer,
						 v_exigible,  
						 v_corriente, 
						 v_monto_30,  
						 v_monto_60,  
						 v_monto_90,
						 v_saldo
						 ;
		let v_apagar = v_exigible;
		let _seleccionar = 0;

		if _ramo_sis = 5 then --salud
			call sp_cob33c(
				 a_compania,
				 a_agencia,
				 _no_documento,
				 _periodo,
				 today
				 ) returning v_por_vencer,
							 v_exigible,  
							 v_corriente, 
							 v_monto_30,  
							 v_monto_60,  
							 v_monto_90,
							 v_saldo
							 ;

			let v_apagar = v_exigible;

			if v_monto_30 > 0 or v_monto_60 > 0 or v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		elif _ramo_sis = 6 then --vida individual
			if v_monto_60 > 0 then
				let _seleccionar = 1;				
			end if
		else
			if v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		end if

		return _no_documento,
		       _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _estatus_poliza,
			   _peri,
			   _cod_subramo,
			   _gestion,
			   _ramo_nom,
			   _subramo_nom,
			   v_apagar,
			   v_saldo,
			   v_exigible,  
			   v_corriente, 
			   v_monto_30,  
			   v_monto_60,  
			   v_monto_90,
			   _no_poliza,
			   v_por_vencer,
			   _asegurado,
			   _seleccionar,
			   trim(_n_acreedor), --_nombre_acreedor,
			   _prima_orig,
			   _nombre_agente,
			   v_exigible,
			   _ramo_sis,
			   _no_renov,
			   _cod_campana,
			   _sel_gestion,
			   _cod_formapag,
			   _nom_formapag,
			   li_fac,
			   _cod_grupo,
			   _n_grupo,
			   _fecha_suspension
			   with resume;
	end foreach;
end procedure

{else
	foreach
	select distinct no_documento
	  into _no_documento
	  from caspoliza
	 where cod_cliente = a_cod_cliente

	 let _cod_campana = '';
	 foreach
		 select	cod_campana,
				a_pagar
		   into	_cod_campana,
				v_apagar
		   from	caspoliza
		  where	cod_cliente = a_cod_cliente
		    and no_documento = _no_documento
		if _cod_campana = a_cod_campana then
			exit foreach;
		end if
	 end foreach;

-- if _tipo_mov <> "R" then
	 let _no_poliza = sp_sis21(_no_documento); --trae ult. vigencia de la poliza.

	 select vigencia_inic,
			vigencia_final,
			cod_ramo,
			estatus_poliza,
			periodo,
			cod_subramo,
			gestion,
			cod_contratante,
			prima_bruta,
			leasing,
			cod_no_renov
	   into	_vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_estatus_poliza,
			_peri,
			_cod_subramo,
			_gestion,
			_cod_contratante,
			_prima_orig,
			_leasing,
			_cod_no_renov
	   from	emipomae
	  where	no_poliza = _no_poliza;

	-- Selecciona el Primer Acreedor de la Poliza
		let _nombre_acreedor = '... SIN ACREEDOR ...';
		let _cod_acreedor    = '';

		let _no_renov = '';        

		select nombre
		  into _no_renov
		  from eminoren
		 where cod_no_renov = _cod_no_renov;
		
		if _no_renov is null then
			let _no_renov = '';
		end if

        let _n_acreedor = ''; 		

		select count(distinct n.nombre)
		  into _nn
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza;

		if _nn > 1 then
			let _cade = ", ";
		else
			let _cade = "";
		end if

		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if


		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if

	    if _n_acreedor is null or trim(_n_acreedor) = "" then
			let _n_acreedor = '... SIN ACREEDOR ...';
		end if

	    if _leasing = 1 then   -- Cuando la poliza es leasing el acreedor se busca en la unidad Caso 06731
			
				select count(distinct n.nombre)
				  into _nn
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza;

			if _nn > 1 then
				if _n_acreedor = '... SIN ACREEDOR ...' then
					let _n_acreedor = '';
				end if
                
				let _cade = ", ";
			else
				let _cade = "";
			end if

			foreach
				select distinct n.nombre
				  into _nn_acree
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza

				let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

			end foreach

			if _nn > 1 then
			   let _n_acreedor[1,1] = "";
			end if
		end if


		let _cod_agente = null;

		foreach 
			 select	cod_agente,
					porc_partic_agt
			   into	_cod_agente,
					_porcentaje
			   from emipoagt
			  where	no_poliza = _no_poliza
			  order by porc_partic_agt desc

				exit foreach;
		end foreach

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		if _gestion is null then
			let _gestion = "p";
		end if

		select nombre,
			   ramo_sis
		  into _ramo_nom,
			   _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select nombre
		  into _subramo_nom
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		call sp_cob33(
			 a_compania,
			 a_agencia,
			 _no_documento,
			 _periodo,
			 today
			 ) returning v_por_vencer,
					     v_exigible,  
					     v_corriente, 
					     v_monto_30,  
					     v_monto_60, } 
					     {v_monto_90,
					     v_saldo
					     ;
		let v_apagar = v_exigible;
		let _seleccionar = 0;

		if _ramo_sis = 5 then --salud
			call sp_cob33c(
				 a_compania,
				 a_agencia,
				 _no_documento,
				 _periodo,
				 today
				 ) returning v_por_vencer,
						     v_exigible,  
						     v_corriente, 
						     v_monto_30,  
						     v_monto_60,  
						     v_monto_90,
						     v_saldo
						     ;

			let v_apagar = v_exigible;

			if v_monto_30 > 0 or v_monto_60 > 0 or v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		elif _ramo_sis = 6 then --vida individual
			if v_monto_60 > 0 then
				let _seleccionar = 1;				
			end if
		else
			if v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		end if

	return _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _peri,
		   _cod_subramo,
		   _gestion,
		   _ramo_nom,
		   _subramo_nom,
		   v_apagar,
		   v_saldo,
		   v_exigible,  
		   v_corriente, 
		   v_monto_30,  
		   v_monto_60,  
		   v_monto_90,
		   _no_poliza,
		   v_por_vencer,
		   _asegurado,
		   _seleccionar,
		   trim(_n_acreedor), --_nombre_acreedor,
		   _prima_orig,
		   _nombre_agente,
		   v_exigible,
		   _ramo_sis,
		   _no_renov,
		   _cod_campana,
		   1
		   with resume;
	end foreach;
end if;	   }

