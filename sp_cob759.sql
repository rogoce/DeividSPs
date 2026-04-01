-- reporte de la gestion de cobros
-- creado    : 20/12/2010 - autor: henry giron
-- sis v.2.0 - d_cobr_sp_cob759_dw1 - deivid, s.a.

drop procedure "informix".sp_cob759;
create procedure "informix".sp_cob759(
a_aviso		char(15),
a_renglon	smallint) 
returning	char(20),	   				-- no_documento
			char(50),	   				-- nombre del cliente
			date, 	       				-- vigencia inicial
			date, 	       				-- vigencia final
			char(50),	   				-- nombre corredor
			varchar(250),  				-- descripcion de la gestion de cobros
			datetime year to second, 	-- fecha_gestion
			char(8),					-- user
			char(50),					-- compania
			char(100),					-- solicitante
			char(100),					-- name_depto
			char(60),					-- fecha_letra
			char(50),					-- nombre_ramo
			char(1),					-- tipo_ramo
			char(10),					-- cod_contratante
			dec(16,2),					-- saldo
			char(10),		  			-- usuario1	   
			char(10),		  			-- usuario2	   
			char(50),		  			-- nombre1		   
			char(50),		  			-- nombre2		   
			char(50),		  			-- cargo1		   
			char(50),		  			-- cargo2		
			char(60);					-- fecha_emision
			   
define _descripcion			varchar(250);
define _solicitante			char(100);
define _name_depto			char(100);
define _fecha_emision		char(60);
define _fecha_letra			char(60);
define v_compania_nombre	char(50); 
define _nombre_corredor		char(50);
define _nombre_cliente		char(50);
define _nombre_ramo			char(50);
define _name_tiram			char(50);
define _nombre1				char(50);
define _nombre2				char(50);
define _cargo1				char(50);
define _cargo2				char(50);
define _no_documento		char(20);
define _user_cancela		char(15);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _usuario1			char(10);
define _usuario2			char(10);
define _user				char(8);
define _periodo_c			char(7); 
define _cod_agente			char(5);
define _ano_char			char(4); 
define _cod_tiporamo		char(3);
define _cod_compania		char(3);
define _cia_depto			char(3);
define _cod_ramo			char(3);
define _mes_char			char(2);
define _estatus_poliza		char(1);
define _tipo_ramo			char(1);
define _ejecuto  		    char(1);
define _por_vencer_c		dec(16,2); 
define _corriente_c			dec(16,2); 
define _exigible_c			dec(16,2); 
define _dias_180_c			dec(16,2); 
define _dias_150_c			dec(16,2); 
define _dias_120_c			dec(16,2); 
define _dias_90_c			dec(16,2); 
define _dias_60_c			dec(16,2); 
define _dias_30_c			dec(16,2); 
define _saldo_c				dec(16,2); 
define _saldo				dec(16,2);
define _fecha_cancelacion2	date;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_cancela		date;
define _fecha_actual		date; 
define _fecha_emite			date;
define _fecha_gestion		datetime year to second;


set isolation to dirty read;

let _fecha_actual = sp_sis26();
let _solicitante = " ";
let _ejecuto = " ";


if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;

-- nombre de la compania
foreach
	select no_documento, 
		   no_poliza,
		   nombre_cliente,    
		   vigencia_inic,    
		   vigencia_final,    
		   nombre_ramo,    
		   saldo,    
		   user_cancela,
		   fecha_cancela,
		   nombre1,
		   cargo1,
		   usuario1,
		   nombre2,
		   cargo2,
		   usuario2,
		   fecha_imprimir,
		   fecha_cancela,
		   ejecuto
	  into _no_documento,
		   _no_poliza,
		   _nombre_cliente,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_ramo,
		   _saldo,
		   _user_cancela,
		   _fecha_cancela,
		   _nombre1,
		   _cargo1,
		   _usuario1,
		   _nombre2,
		   _cargo2,
		   _usuario2,
		   _fecha_emite,
		   _fecha_cancelacion2,
		   _ejecuto
	  from avisocanc
	 where no_aviso = a_aviso
	   and renglon = a_renglon 

    -- Solicitante - Fecha_cancela
    call sp_sis20(_fecha_cancela) returning _fecha_letra;
    -- Solicitante - Fecha_emite
    call sp_sis20(_fecha_emite) returning _fecha_emision;

    foreach	
		select cia_depto,
			   descripcion 
		  into _cia_depto,
			   _solicitante 
		  from segv05:insuser  
		 where usuario = _user_cancela	
		exit foreach;	
	end foreach 

    foreach																							 
		select trim(nombre)																				 
		  into _name_depto
		  from segv05:insdepto 
		 where cod_depto = _cia_depto
		exit foreach;
	end foreach

	  -- LET _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   cod_compania,
		   fecha_cancelacion,
		   estatus_poliza,
		   cod_ramo
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante,
		   _cod_compania,
		   _fecha_cancelacion,
		   _estatus_poliza,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo in ('002','020') then
	   let _tipo_ramo  = "A"; 		--	LET _nom_tiporamo = 'AUTOMOVIL';
	   if _ejecuto = "1" then
			let _vigencia_final = _fecha_cancelacion2;
	   end if
	else
		select cod_tiporamo 
		  into _cod_tiporamo 
		  from prdramo 
		 where cod_ramo = _cod_ramo; 

		select nombre 
		  into _name_tiram 
		  from prdtiram 
		 where cod_tiporamo = _cod_tiporamo; 
		 
		if _cod_tiporamo = "001" then
			let _tipo_ramo  = "B"; --  LET _nom_tiporamo = 'PERSONAS';		
		elif _cod_tiporamo = "002" then
			let _tipo_ramo  = "C"; --  LET _nom_tiporamo = 'PATRIMONIALES';
		elif _cod_tiporamo = "003" then
			let _tipo_ramo  = "D"; --  LET _nom_tiporamo = 'FIANZA';
		else
			let _tipo_ramo  = "E"; --  LET _nom_tiporamo = 'POR DEFINIR';
		end if
	end if   

--	 let _estatus_poliza = 2;

	if _estatus_poliza = 2 then --cancelada
		if _fecha_cancelacion2 is not null then
			let _vigencia_final = _fecha_cancelacion2;
		end if
	 end if

	let v_compania_nombre = sp_sis01(_cod_compania); 

{	SELECT nombre 
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;	 }

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre
	  into _nombre_corredor
	  from agtagent
	 where cod_agente = _cod_agente;

	foreach
		select fecha_gestion, 
			   desc_gestion,
			   user_added
		  into _fecha_gestion,
			   _descripcion,
			   _user
		  from cobgesti
		 where no_documento = _no_documento
		   and date(fecha_gestion) >= _vigencia_inic
		   and date(fecha_gestion) <= _vigencia_final
		 order by fecha_gestion desc

		call sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
		returning	_por_vencer_c,	   
					_exigible_c,	   
					_corriente_c,	   
					_dias_30_c,	   
					_dias_60_c,	   
					_dias_90_c,	   
					_dias_120_c,	   
					_dias_150_c,	   
					_dias_180_c,	   
					_saldo_c;	

		return	_no_documento,
				_nombre_cliente,
				_vigencia_inic,
				_vigencia_final,
				_nombre_corredor,
				_descripcion,
				_fecha_gestion,
				_user,
				v_compania_nombre,
				_solicitante,
				_name_depto,
				_fecha_letra,
				_nombre_ramo,
				_tipo_ramo,
				_cod_contratante,
				_saldo_c, --_saldo,
				_usuario1,
				_usuario2,
				_nombre1,
				_nombre2,
				_cargo1,
				_cargo2,
				_fecha_emision with resume;		  
	end foreach
end foreach
end procedure;