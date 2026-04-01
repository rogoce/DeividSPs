-- Detalle Cancelaciones - CESE
-- Creado    : 16/04/2024 -- Autor:Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro377a;
create procedure "informix".sp_pro377a(a_periodo char(7),a_periodo2 char(7),a_agente CHAR(255))
returning varchar(50)	as	asegurado,
char(20)	    as	cedula_asegurado,
varchar(50)	as	contratante,
char(20)	    as	cedula_contratante,
char(15)    as	celular,
char(15)	as	Telf_casa,
char(15)	as	Telf_Oficina,
char(15)	as	Correo_electronico,
char(20)	as	poliza,
char(50)	as	ramo,
varchar(10)	as	Placa,
char(15)	as	Estado_Poliza,
varchar(20)	as	Forma_de_Pago,
varchar(50)	as	Acreedor,
date	    as	Vigencia_Inicial,
date	    as	Vigencia_Final,
char(10)	as	Nueva_Renovada,
char(50)	as	Motivo_No_Renov,
date	    as	Fecha_ult_Pago,
DEC(16,2)	as	Monto_ult_Pago,
varchar(50)	as	Nombre_Grupo,
DEC(16,2)	as	prima_bruta,
DEC(16,2)	as	Saldo,
DEC(16,2)	as	Por_vencer,
DEC(16,2)	as	Exigible,
DEC(16,2)	as	corriente,
DEC(16,2)	as	Monto_30,
DEC(16,2)	as	Monto_60,
DEC(16,2)	as	Monto_90,
DEC(16,2)	as	No_Pagos,
date        as	Fecha_cese,
DEC(16,2)	as	Monto_cese,
varchar(80)	as	Nombre_agente,
date        as	Fecha_Susp_cobertura
;


begin
define _n_cliente	varchar(50);
define _no_cedula_aseg	char(20);
define _n_contratante varchar(50);
define  _no_cedula_cont	char(20);
define  _celular	char(15);
define  _Telf_casa	char(15);
define  _Telf_Oficina	char(15);
define _email	char(15);
define _no_documento	char(20);
define v_desc_ramo	char(50);
define  _Placa	varchar(10);
define _n_Estado_Poliza	char(15);
define _n_form_pag	varchar(20);
define  _n_acreedor	varchar(50);
define 	_vigencia_inic	date;
define 	_vigencia_final	date;
define 	_fecha_cese	date;
define 	_nueva_renov	char(1);
define 	_motivo_No_Renov	char(50);
define 	_Fecha_ult_Pago	date;
define 	_Monto_ult_Pago	DEC(16,2);
define  _n_grupo	varchar(50);
define 	_prima_bruta DEC(16,2);
define 	_Saldo	DEC(16,2);
define 	_Por_vencer	DEC(16,2);
define 	_Exigible	DEC(16,2);
define 	_corriente	DEC(16,2);
define 	_Monto_30	DEC(16,2);
define 	_Monto_60	DEC(16,2);
define 	_Monto_90	DEC(16,2);
define 	_No_Pagos	DEC(16,2);
define 	_cia CHAR(50);
define  _grupo	char(5);
define 	_no_aviso	char(5);
define 	_Fecha_Susp	date;
define 	_cod_ramo	char(03);
define 	 _periodo	char(7);
define 	 _codigo	char(16);
define 	_prima_neta	dec(16,2);
define 	_prima_bruta2	dec(16,2);
define 	_no_poliza	char(10);
define 	_no_endoso	char(5);
define 	v_reaseguro	dec(16,2);
define 	_cod_contratante,_renov_desc   char(10);
define 	_cod_mov char(3);
define 	_tipo	char(1);
define 	_cod_tipocan char(3);
define 	_cod_grupo	 char(5);
define _estatus_poliza    smallint;
define _cod_formapag      char(3);
define _cod_no_renov	char(3);
define v_nombre_agente		varchar(80);
define _cod_agente			char(5);
DEFINE v_filtros           CHAR(255);
define _monto_cese  DEC(16,2);


let _cia = sp_sis01('001');	
let v_filtros = '';
let _prima_bruta = 0;
	drop table if exists tmp_cancela;
	create temp table tmp_cancela
			(no_documento		char(20),
			cod_ramo			char(03),
			prima_neta			dec(16,2),
			prima_bruta			dec(16,2),
			no_poliza			char(10),
			no_endoso			char(5),
			periodo				char(7),
			cod_contratante     char(10),
			cod_tipocan         char(3),
			seleccionado		smallint default 1);
--   CREATE INDEX i_cancela5 ON tmp_cancela(cod_contratante);

drop table if exists tmp_corredor;
	create temp table tmp_corredor
			(asegurado	varchar(50),
			cedula_asegurado	char(20),
			contratante	varchar(50),
			cedula_contratante	char(20),
			celular	char(15),
			Telf_casa	char(15),
			Telf_Oficina	char(15),
			Correo_electronico	char(15),
			poliza	char(20),
			ramo	char(50),
			Placa	varchar(10),
			Estado_Poliza	char(15),
			Forma_de_Pago	varchar(20),
			Acreedor	varchar(50),
			Vigencia_Inicial	date,
			Vigencia_Final	date,			
			Nueva_Renovada	char(10),
			Motivo_No_Renov	char(50),
			Fecha_ult_Pago	date,
			Monto_ult_Pago	DEC(16,2),
			Nombre_Grupo	varchar(50),
			prima_bruta	DEC(16,2),
			Saldo	DEC(16,2),
			Por_vencer	DEC(16,2),
			Exigible	DEC(16,2),
			corriente	DEC(16,2),
			Monto_30	DEC(16,2),
			Monto_60	DEC(16,2),
			Monto_90	DEC(16,2),
			No_Pagos	DEC(16,2),
			cia	CHAR(50),
			grupo	char(5),
			Aviso_Canc	char(5),
			Fecha_Susp_cobertura	date,
			cod_ramo	char(03),
			periodo	char(7),
			codigo	char(16),
			Nombre_agente	varchar(80),
			fecha_cese  date,
			monto_cese  DEC(16,2),
			cod_agente		CHAR(5)	,
			seleccionado		smallint default 1);
--   CREATE INDEX i_cancela5 ON tmp_cancela(cod_contratante);


	let v_desc_ramo      = null;
	let _n_cliente       = null;

	set isolation to dirty read;

	select cod_endomov
	  into _cod_mov
	  from endtimov
	  where tipo_mov = 6  and cod_endomov = '032';

	foreach
		select e.no_documento,
			   e.cod_ramo,
			   e.cod_contratante,
			   x.no_poliza,
			   x.no_endoso,
			   x.prima_neta,
			   x.prima_bruta,  
			   x.cod_tipocan,
			   x.periodo
		  into _no_documento,
			   _cod_ramo,
			   _cod_contratante,
			   _no_poliza,
			   _no_endoso,
			   _prima_neta,
			   _prima_bruta,
			   _cod_tipocan,
			   _periodo
	     from emipomae e, endedmae x, emipoagt c , agtagent k
	    where e.cod_ramo in ('002','020','023')  
		  and e.no_poliza =  c.no_poliza
		  and x.no_poliza =  c.no_poliza
          and c.cod_agente = k.cod_agente
	      and e.no_poliza    = x.no_poliza
	      and x.periodo     >= a_periodo
		  and x.periodo     <= a_periodo2
	      and x.actualizado  = 1
	      and x.cod_endomov  = _cod_mov
		  and e.estatus_poliza = '1'   and e.cod_no_renov = '039'
		 -- and k.cod_agente in ('02901','01589','02311')
		--  and x.cod_tipocan  in('001','010','013')
	    order by e.cod_ramo		
			
       insert into tmp_cancela
       values(  _no_documento,
				_cod_ramo,
				_prima_neta,
				_prima_bruta,
				_no_poliza,
				_no_endoso,
				_periodo,
				_cod_contratante,
				_cod_tipocan,
				1);
    end foreach
	
	foreach
		select no_documento,
			   cod_ramo,
			   no_poliza,
			   no_endoso,
			   prima_neta,
			   cod_contratante,
			   cod_tipocan
		  into _no_documento,
			   _cod_ramo,
			   _no_poliza,
			   _no_endoso,
			   _prima_neta,
			   _cod_contratante,
			   _cod_tipocan
		  from tmp_cancela
		 where seleccionado = 1
		 order by cod_ramo
		 
		foreach with hold
		    select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 exit foreach;
		end foreach		 

	   --ramo
       select nombre
         into v_desc_ramo
         from prdramo
        where cod_ramo = _cod_ramo;

		select periodo
	     into _periodo
		 from endedmae
		where no_poliza = _no_poliza
		  and no_endoso = _no_endoso;

		select cod_grupo,
			estatus_poliza, 
			cod_formapag, 
			vigencia_inic,
			vigencia_final,
			cod_no_renov, 
			nueva_renov,
			fecha_ult_Pago,
			prima_bruta,
			Saldo,
			No_Pagos
	     into _cod_grupo,
			 _estatus_poliza,
			 _cod_formapag, 
			 _vigencia_inic, 
			 _vigencia_final,
			 _cod_no_renov, 
			 _nueva_renov,
			 _Fecha_ult_Pago,
			 _prima_bruta2,
			 _Saldo,
			 _No_Pagos
		 from emipomae
		where no_poliza = _no_poliza;
		
		IF _Saldo IS NULL THEN
		   LET _Saldo = 0;
		END IF		
		
		let _n_Estado_Poliza = '';
		
		if _estatus_poliza = 1 then
		  let _n_Estado_Poliza = "VIGENTE";
		elif _estatus_poliza = 2 then
		  let _n_Estado_Poliza = "CANCELADA";
		elif _estatus_poliza = 3 then
		  let _n_Estado_Poliza = "VENCIDA";
		elif _estatus_poliza = 4 then
		  let _n_Estado_Poliza = "ANULADA";
		else
		  let _n_Estado_Poliza = "NO APLICA";
		end if	
		
		let _n_form_pag = '';
       select nvl(upper(nombre),'') 
	     into _n_form_pag 
	     from cobforpa 
	    where cod_formapag = _cod_formapag;		
		
		let _n_grupo = '';
		select nombre
	     into _n_grupo
		 from cligrupo
		where cod_grupo = _cod_grupo;
        

        select nombre,
			cedula,
			e_mail,	   
			celular,
			telefono1,
			telefono2
		  into _n_cliente,
			_no_cedula_aseg,
			_email,
			_celular,
			_Telf_casa,
			_Telf_Oficina
		  from cliclien
		 where cod_cliente = _cod_contratante;
		 
		foreach
			select first 1 distinct nvl(n.nombre,''), trim(n.cedula) ---e.cod_asegurado
			  into _n_contratante, _no_cedula_cont
			  from  emipouni e, cliclien n
			 where e.cod_asegurado = n.cod_cliente
			   and e.no_poliza = _no_poliza			   
			   exit foreach;
		end foreach		 		

		 
		 LET _Placa = '';
		foreach
		  SELECT  first 1 distinct nvl(emivehic.placa,'')
			INTO _Placa
		   FROM endmoaut,   
				 emivehic,  
				 emimodel, 
				 endeduni,   
				 endedmae
		   WHERE ( emivehic.no_motor = endmoaut.no_motor ) and  
				 ( endeduni.no_poliza = endmoaut.no_poliza ) and  
				 ( endeduni.no_endoso = endmoaut.no_endoso ) and  
				 ( endeduni.no_unidad = endmoaut.no_unidad ) and  
				 ( endedmae.no_poliza = endeduni.no_poliza ) and  
				 ( endedmae.no_endoso = endeduni.no_endoso ) and  
				 ( emivehic.cod_modelo = emimodel.cod_modelo ) and  
				 ( endedmae.no_poliza = _no_poliza) and  
				 ( endedmae.no_endoso = _no_endoso) and 				 
				 ( endedmae.actualizado = 1)  			   			   
			exit foreach;
			
		end foreach	
		IF _Placa IS NULL THEN
		   LET _Placa = '';
		END IF		
		
        let _n_acreedor = '';
		foreach
			select  first 1 distinct nvl(n.nombre,'')
			  into _n_acreedor
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza
		end foreach		
		
		-- Renovacion de la Poliza

		if _nueva_renov = 'N' then
			let _renov_desc = "NUEVA";
		elif _nueva_renov = 'R' then
			let _renov_desc = "RENOVADA";
	  	end if		

		if _cod_tipocan = '001' then
			let _codigo = 'FALTA DE PAGO';
		elif _cod_tipocan = '010' then
			let _codigo = 'SALDO PENDIENTE';
		else
			let _codigo = 'INCOBRABLE';
		end if
		
	       let _motivo_No_Renov = '';
		 
		  SELECT trim(nombre)||" - "||trim(cod_no_renov)
			into _motivo_No_Renov
			FROM eminoren   
			where cod_no_renov = _cod_no_renov;	 		 
		 
 -- Determina la fecha del ultimo pago y el monto
		FOREACH
		SELECT monto,
			   fecha
		  INTO _Monto_ult_Pago,
			   _Fecha_ult_Pago
		  FROM cobredet
		 WHERE doc_remesa   = _no_documento	-- Recibos de la Poliza
		   AND actualizado  = 1			    -- Recibo este actualizado
		   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
		   AND periodo     <= _periodo	    -- No Incluye Periodos Futuros
		 ORDER BY fecha DESC
			EXIT FOREACH;
		END FOREACH		 
		
	--selecciona los nombres de los grupos
	select trim(nombre)||" - "||trim(cod_grupo), cod_grupo
	  into _n_grupo, _grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;		
	 
		CALL sp_cob33(
			 '001',
			 '001',
			 _no_documento,
			 _periodo,
			 today
			 ) RETURNING _Por_vencer,
					     _Exigible,  
					     _corriente, 
					     _Monto_30,  
					     _Monto_60,  
					     _Monto_90,
					     _Saldo
					     ;		
						 
		select max(no_aviso)
		into _no_aviso
		from avisocanc
		where no_documento in (_no_documento)
		and (estatus = 'Z' or cancela = 1 ); --trim(motivo) = 'Poliza Cancelada');
		
		select max(fecha_suspension)
		into _Fecha_Susp
		from emipoliza
		where no_documento in (_no_documento);
		--group by 1
		--order by 1 desc;		
		
	--selecciona los nombres de los corredores
	select trim(nombre)||" - "||trim(cod_agente)
	  into v_nombre_agente
     from agtagent
	 where cod_agente = _cod_agente;	
		  
	let _fecha_cese = null; 
	let _monto_cese = 0.00; 
	foreach 
		select e.fecha_emision, e.prima_bruta  --e.prima_neta
		  into _fecha_cese, _monto_cese
		  from endedmae e
		 where e.no_poliza = _no_poliza
		   and e.no_endoso = _no_endoso	
		   and e.cod_endomov  = _cod_mov
		   and e.actualizado = 1
		 order by 1 desc
		exit foreach;					   
	end foreach	 
	
		select prima_bruta
	     into _prima_bruta
		 from endedmae
		where no_poliza = _no_poliza
		  and no_endoso ='00000' 
		  and cod_endomov = '011'   
		  and actualizado = 1;	
	 
       insert into tmp_corredor
       values(  _n_cliente,
				_no_cedula_aseg,
				_n_contratante,
				_no_cedula_cont,
				_celular,
				_Telf_casa,
				_Telf_Oficina,
				_email,
				_no_documento,
				v_desc_ramo,
				_Placa,
				_n_Estado_Poliza,
				_n_form_pag,
				_n_acreedor,
				_vigencia_inic,
				_vigencia_final,
				_renov_desc,
				_motivo_No_Renov,
				_Fecha_ult_Pago,
				_Monto_ult_Pago,
				_n_grupo,
				_prima_bruta,
				_Saldo,
				_Por_vencer	,
				_Exigible,
				_corriente,
				_Monto_30,
				_Monto_60,
				_Monto_90,
				_No_Pagos,
				_cia,
				_grupo,
				_no_aviso,
				_Fecha_Susp,
				_cod_ramo,
				_periodo,
				_codigo,
				v_nombre_agente,
				_fecha_cese,
				_monto_cese,
                _cod_agente,				
				1);
    end foreach
	
IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_corredor
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_corredor
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

	
	foreach
		select distinct asegurado,
			cedula_asegurado,
			contratante,
			cedula_contratante,
			celular,
			Telf_casa,
			Telf_Oficina,
			Correo_electronico,
			poliza,
			ramo,
			Placa,
			Estado_Poliza,
			Forma_de_Pago,
			Acreedor,
			Vigencia_Inicial,
			Nueva_Renovada,
			Motivo_No_Renov,
			Fecha_ult_Pago,
			Monto_ult_Pago,
			Nombre_Grupo,
			prima_bruta,
			Saldo,
			Por_vencer,
			Exigible,
			corriente,
			Monto_30,
			Monto_60,
			Monto_90,
			No_Pagos,
			cia,
			grupo,
			max(Aviso_Canc),
			max(Fecha_Susp_cobertura),
			cod_ramo,
			max(periodo),
			codigo,
			Nombre_agente,
            Fecha_cese,
			monto_cese,
            Vigencia_Final			
		  into _n_cliente,
				_no_cedula_aseg,
				_n_contratante,
				_no_cedula_cont,
				_celular,
				_Telf_casa,
				_Telf_Oficina,
				_email,
				_no_documento,
				v_desc_ramo,
				_Placa,
				_n_Estado_Poliza,
				_n_form_pag,
				_n_acreedor,
				_vigencia_inic,
				_renov_desc,
				_motivo_No_Renov,
				_Fecha_ult_Pago,
				_Monto_ult_Pago,
				_n_grupo,
				_prima_bruta,
				_Saldo,
				_Por_vencer	,
				_Exigible,
				_corriente,
				_Monto_30,
				_Monto_60,
				_Monto_90,
				_No_Pagos,
				_cia,
				_grupo,
				_no_aviso,
				_Fecha_Susp,
				_cod_ramo,
				_periodo,
				_codigo,
				v_nombre_agente,
				_Fecha_cese,
				_monto_cese,
				_Vigencia_Final
		  from tmp_corredor
		 where seleccionado = 1
		 group by asegurado,
			cedula_asegurado,
			contratante,
			cedula_contratante,
			celular,
			Telf_casa,
			Telf_Oficina,
			Correo_electronico,
			poliza,
			ramo,
			Placa,
			Estado_Poliza,
			Forma_de_Pago,
			Acreedor,
			Vigencia_Inicial,
			Nueva_Renovada,
			Motivo_No_Renov,
			Fecha_ult_Pago,
			Monto_ult_Pago,
			Nombre_Grupo,
			prima_bruta,
			Saldo,
			Por_vencer,
			Exigible,
			corriente,
			Monto_30,
			Monto_60,
			Monto_90,
			No_Pagos,
			cia,
			grupo,
			--max(Aviso_Canc),
			--max(Fecha_Susp_cobertura),
			cod_ramo,
			--max(periodo),
			codigo,
			Nombre_agente,
			Fecha_cese,
			monto_cese,
			Vigencia_Final
		 order by Nombre_agente	 
						 
  {     return _n_cliente,
			_no_cedula_aseg,
			_n_contratante,
			_no_cedula_cont,}
			
       return _n_contratante,
			_no_cedula_cont,	
			_n_cliente,
			_no_cedula_aseg,					
			_celular,
			_Telf_casa,
			_Telf_Oficina,
			_email,
			_no_documento,
			v_desc_ramo,
			_Placa,
			_n_Estado_Poliza,
			_n_form_pag,
			_n_acreedor,
			_vigencia_inic,
			_Vigencia_Final,
			_renov_desc,
			_motivo_No_Renov,
			_Fecha_ult_Pago,
			_Monto_ult_Pago,
			_n_grupo,
			_prima_bruta,
			_Saldo,
			_Por_vencer	,
			_Exigible,
			_corriente,
			_Monto_30,
			_Monto_60,
			_Monto_90,
			_No_Pagos,
			_Fecha_cese,
			_monto_cese,
			v_nombre_agente	,
			_Fecha_Susp			
			with resume;

    end foreach
--drop table tmp_cancela;
end
end procedure;
