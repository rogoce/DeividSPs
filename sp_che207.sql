--********************************************************************************************
-- Procedimiento que Actualiza las primas cobradas nuevas para convencion Tropical Cancun 2015
--********************************************************************************************
-- Creado    : 12/06/2012 - Autor: Henry Giron
-- Modificado: 04/01/2015 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che207;

CREATE PROCEDURE sp_che207(a_compania CHAR(3))
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50);
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_prima_n        DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _monto_p			DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _agente_agrupado char(5);
define _prima_cobrada   dec(16,2);
define _prima_cobrada2   dec(16,2);
define _retro            smallint;
define a_periodo_ini    char(7);
define _cod_agente1     char(5);
define _declarativa     smallint;
--define _valor           smallint;
define _nueva_renov     char(1);
define _cantidad_pol    integer;
define _n_agente        char(50);
define _n_ramo          char(50);
define _categoria       smallint;
define _cod_agente2     char(5);
define _sw              smallint;
define _prima_2011		dec(16,2);
define _prima_nva_2011	dec(16,2);
define _cnt_poliza		smallint;
define _cod_formapag    char(3);
define _fecha_aplico    date;
define _prima_cob2014   dec(16,2);
define _prima_cob_nva   dec(16,2);
define _cnt_pol         integer;
define _meses           smallint;
define _valor           decimal(16,2);
define _cod_perpago		char(3);
define _unificar        integer;
define _prima_neta		decimal(16,2);
define _prima_suscrita  decimal(16,2);
define _cnnt            integer;


-- Se desactivo la carga de Cancun 2015  
-- Era hasta el 30 de Septiembre de 2012
-- Demetrio Hurtado	(02/10/2015)

 return 0;

--SET DEBUG FILE TO "sp_che207a.trc";
--TRACE ON;

let _error   		= 0;
let _porc_coas_ancon = 0;
let _forma_pag      = 0;
let _porc_comis     = 0;
let _porc_comis2    = 0;
let _prima_45       = 0;
let _prima_90       = 0;
let _cnt            = 0;
let _monto_m        = 0;
let _monto_p        = 0;
let _prima_bruta    = 0;
let _prima_cobrada  = 0;
let _prima_cobrada2 = 0;
let _retro          = 0;
let _declarativa    = 0;
let _valor          = 0;
let v_prima_n       = 0;
let _sw             = 0;
let _prima_2011		= 0;
let _prima_nva_2011 = 0;
let _cnt_poliza		= 0;
let _prima_suscrita = 0;


CREATE TEMP TABLE tmp_tropi(
	cod_agente		CHAR(15),
	no_documento    CHAR(20),
	prima           DEC(16,2),
	cantidad_pol    integer default 0,
	cod_ramo        char(3),
	categoria       smallint,
	prima_suscrita  decimal(16,2),
	PRIMARY KEY		(cod_agente, no_documento)
	) WITH NO LOG;

CREATE INDEX i_boni1 ON tmp_tropi(cod_agente);
CREATE INDEX i_boni2 ON tmp_tropi(no_documento);

SET ISOLATION TO DIRTY READ;

delete from tropical2;

let _valor = sp_che216();	--insertar corredores nuevos a tabla tropical

select * 
  from tropical
  into temp prueba;

insert into tropical2
select * 
  from prueba;

drop table prueba;

let _porc_coas_ancon = 100;
let _sw = 0;

FOREACH
	select cod_agente, categoria
	  into _cod_agente, _categoria
	  from tropical
	 order by categoria

	 foreach
		 select e.no_documento
		   into _no_documento
		   from emipomae e, emipoagt t
		  where e.no_poliza         = t.no_poliza
            and e.cod_compania      = a_compania
		    and e.actualizado       = 1
			and e.nueva_renov       = "N"
		    and e.fecha_suscripcion >= "01/01/2015"  
			and e.fecha_suscripcion <= "30/04/2015"	
            and t.cod_agente        = _cod_agente
		   group by e.no_documento
		   order by e.no_documento

		 let _cod_agente2 = _cod_agente;	
		 let _no_poliza = sp_sis21(_no_documento);

			select cod_grupo,
			       cod_ramo,
			       cod_pagador,
			       cod_contratante,
			       cod_subramo,
				   cod_tipoprod,
				   nueva_renov,
				   prima_suscrita,
				   cod_formapag,
				   cod_perpago,
				   prima_suscrita
			  into _cod_grupo,
			       _cod_ramo,
			       _cod_pagador,
			       _cod_contratante,
			       _cod_subramo,
				   _cod_tipoprod,
				   _nueva_renov,
				   v_prima_n,
				   _cod_formapag,
				   _cod_perpago,
				   _prima_suscrita
			  from emipomae
			 where no_poliza = _no_poliza;

			if _nueva_renov = "N" then
			else
				continue foreach;
			end if
			
			{if _cod_ramo = '018' and _cod_subramo = '012' then	--Se excluyen las polizas colectivas.
				continue foreach;
			end if}
			
			if v_prima_n < 50 then --excluir primas menores de 50$
				continue foreach;
			end if
				
			{if _cod_ramo in('023') then
				continue foreach;
			end if}

			if _cod_grupo in("00000","1000") then --excluir estado
				continue foreach;
			end if

		   {	select count(*)
			  into _cnt
			  from emipouni
			 where no_poliza = _no_poliza;}

			if _no_documento = "0212-00459-06" then

				-- No Evaluar la cantidad de Unidades de esta poliza
				-- De acuerdo a correo del 10 de sept de 2012
				-- Demetrio Hurtado

			else

				-- Para los casos de Incendio (Lucro Cesante, Excedente, Cobertura Normal) y de 
				-- auto (Cabezal y Remolque)
				-- Demetrio Hurtado (18/09/2012)

			{	if _cnt > 3 then	  -- NO FLOTAS
					continue foreach;
				end if}

			end if

			SELECT tipo_produccion
			  INTO _tipo_prod
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			IF _tipo_prod = 4 THEN	-- excluir Reaseguro Asumido
			   CONTINUE FOREACH;
			END IF

		{	IF _tipo_prod = 3 THEN	--excluir coas minoritario
			   CONTINUE FOREACH;
			END IF

		   if _tipo_prod = 2 then  --coas mayoritario
			   CONTINUE FOREACH;
		   end if}

			select count(*)
			  into _cnt
			  from emifafac
			 where no_poliza = _no_poliza;

			if _cnt > 0 then		--excluir los facultativos
				continue foreach;
			end if 

			select cedula
			  into _cedula_paga
			  from cliclien
			 where cod_cliente = _cod_pagador;

			select cedula
			  into _cedula_cont
			  from cliclien
			 where cod_cliente = _cod_contratante;

		   select count(*)
		     into _cnt
		     from endedmae
		    where no_poliza   = _no_poliza
			  and actualizado = 1
		      and cod_endomov in ('003','012','002')  -- rehabilitacion o cambio de corredor en el periodo no va
		      and fecha_emision >= "01/01/2015"  
		      and fecha_emision <= "30/04/2015";

			if _cnt > 0 then
				if _no_poliza = '891442' or _no_poliza = '890091' then	--esta poliza tiene cambio de corredor pero es del mismo corredor
				else
					continue foreach;
				end if	
			end if

			INSERT INTO tmp_tropi(cod_agente,no_documento,prima,cantidad_pol,cod_ramo,categoria,prima_suscrita)
			VALUES(_cod_agente,_no_documento,0,1,_cod_ramo,_categoria,_prima_suscrita);
			
			foreach

				 SELECT	d.no_remesa,
				        d.renglon,
				        d.no_recibo,
				        d.fecha,
				        d.monto,
				        d.prima_neta,
				        d.tipo_mov,
						m.cod_banco,
						m.cod_chequera,
						c.porc_partic_agt
				   INTO	_no_remesa,
					    _renglon,
					    _no_recibo,
					    _fecha,
					    _monto,
					    _prima,
					    _tipo_mov,
						_cod_banco,
						_cod_chequera,
						_porc_partic
				   FROM	cobredet d, cobremae m, cobreagt c
				  WHERE	d.no_remesa    = m.no_remesa
				    AND d.no_remesa    = c.no_remesa
				    AND d.renglon      = c.renglon
				    AND d.cod_compania = a_compania
					AND d.doc_remesa   = _no_documento
				    AND d.actualizado  = 1
					AND d.tipo_mov     IN ('P','N')
					AND d.fecha        >= "01/01/2015"
					AND d.fecha        <= "30/04/2015"
					AND m.tipo_remesa  IN ('A', 'M', 'C')
					AND c.cod_agente   IN (_cod_agente)  --,_cod_agente2)
			      ORDER BY d.fecha,d.no_recibo,d.no_poliza

				-- Se elimino la candicion de evaluar por recibos menores de 50
				-- De acuerdo a memo del 7 de sep de 2012
				-- Demetrio Hurtado

				 --if _prima < 50 then --excluir recibos menores de 50$
				 --	continue foreach;
				 --end if
				if _cod_tipoprod = "001" then

					select porc_partic_coas
					  into _porc_coas_ancon
					  from emicoama
					 where no_poliza    = _no_poliza
					   and cod_coasegur = '036';

					if _porc_coas_ancon is null then
						let _porc_coas_ancon = 0.00;
					end if
				else
					let _porc_coas_ancon = 100;
				end if
				
				  SELECT tipo_agente,
						 estatus_licencia,
						 cedula
					INTO _tipo_agente,
					     _estatus_licencia,
				  	     _cedula_agt
				    FROM agtagent
				   WHERE cod_agente = _cod_agente;

					  if trim(_cedula_agt) = trim(_cedula_paga) then   --No sea ni el pagador
						 continue foreach;
					 end if
					
					  if trim(_cedula_agt) = trim(_cedula_cont) then   --No sea ni el contratante
						 continue foreach;
					 end if

				   	  IF _tipo_agente <> "A" then	--solo agentes
						 continue foreach;
					 END IF

					  IF _estatus_licencia <> "A" then  --El corredor debe estar activo
						 continue foreach;
					 END IF
					 
					if _cod_formapag in('003','005') then	--Es TCR o ACH
						select count(*)
						  into _cnt
						  from tmp_tropi 
						 WHERE cod_agente   = _cod_agente
						   AND no_documento = _no_documento
						   and prima        <> 0;
						if _cnt > 0 then
								continue foreach;
						end if	   
						if _cod_ramo = '018' then
								select meses
								  into _meses
								  from cobperpa
								 where cod_perpago = _cod_perpago;
								let _valor = 0;
								if _cod_perpago = '001' then
									let _meses = 1;
								end if
								if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
									let _meses = 12;
								end if	
								let _valor = 12 / _meses;
								let v_prima_n = v_prima_n * _valor;
								let _prima = v_prima_n;
						else
								let _prima = v_prima_n;
						end if
					end if
					
				    let _monto_p = 0;
			        let _prima   = (_porc_coas_ancon * _prima) / 100;
				    let _monto_p = _prima * (_porc_partic / 100);

				   BEGIN

				   	  ON EXCEPTION IN(-239)

						   	UPDATE tmp_tropi
							   SET prima        = prima + _monto_p
							 WHERE cod_agente   = _cod_agente
							   AND no_documento = _no_documento;

					 END EXCEPTION

					 INSERT INTO tmp_tropi(cod_agente,no_documento,prima,cantidad_pol,cod_ramo,categoria)
					 VALUES(_cod_agente,_no_documento,_monto_p,1,_cod_ramo,_categoria);

				  END

			end foreach

		END FOREACH

end foreach

foreach

	 select cod_agente,
	        no_documento,
			prima,
			cantidad_pol,
			cod_ramo,
			categoria,
			prima_suscrita
	   into _cod_agente,
	        _no_documento,
			_monto_p,
			_cantidad_pol,
			_cod_ramo,
			_categoria,
			_prima_suscrita
	   from tmp_tropi
	  order by cod_agente
	  
	--UNIFICACIONES
	if _cod_agente in('01481') then --Unificar Jose Caballero a Marta Caballero
	    let _cod_agente = "01555";
	end if
	if _cod_agente in('01480','00492') then --Unificar Ricardo Caballero,Ases del seg. a Patricia Caballero
	    let _cod_agente = "01479";
	end if
	if _cod_agente in('01480','00492') then --Unificar Ricardo Caballero,Ases del seg. a Patricia Caballero
	    let _cod_agente = "01479";
	end if
	if _cod_agente in('02129','02130','02050','01001','01002','01609','01005') then --Unificar Felix Abadia
	    let _cod_agente = "01001";
	end if
	let _unificar = 0;	 --Unificar FF Seguros

	SELECT count(*)
	  INTO _unificar
	  FROM agtagent 
	 WHERE cod_agente      = _cod_agente
	   AND agente_agrupado = "01068";

	if _unificar <> 0 then
		let _cod_agente = "01068";
	end if
	if _cod_agente in('00636','00732','00865','00731') then --Unificar Jovani Mora,Quitza Paz, Rogelio Becerra, Alberto camacho A Servicios Internacionales.
	    let _cod_agente = "01435";
	end if
	--Unificar doulos insurance consultants,logos insuance consultants,logos insuance consultants,juan carlos sanchez,juan carlos sanchez,chung wai chun,chun wai chun, katia mariza dam de spagnuolo
    --katia mariza dam de spagnuolo. adela latty	A Doulos insurance consultants, s.a. (DICSA)
	if _cod_agente in('01837','01569','01838','01315','01834','00623','01836','01575','01835','02201') then
	    let _cod_agente = "01048";
	end if
	--Afta Insurance Services(santiago)(02155), Asesora Tefi S.A.(00095), Ithiel Cesar Trib.(00130) , Seguros ICT, S.A(00235)
	if _cod_agente in ("02155","00095","00130","00235") then
	    let _cod_agente = "01266";
	end if
	
	-- Unificar todos los KAM A Kam y asociados (panama), s.a.
	if _cod_agente IN ("00133","01746","01749","01852","02004","02075","02124") then  
		let _cod_agente = "00218";													
	end if
	-- Unificar joel quintero A Noel Quintero
	if _cod_agente IN ("01880") then  
		let _cod_agente = "00395";													
	end if	
	-- Unificar corporacion comercial A Tuesca & asociados.
	if _cod_agente IN ("00239") then  
		let _cod_agente = "00946";													
	end if
	-- Unificar seg morrice y urrutia chitre seg morrice y urrutia santiago A semusa.
	if _cod_agente IN ("01853","01814") then  
		let _cod_agente = "00270";													
	end if
	-- Unificar seguros nacionales (david) A seg nacionales, s.a.
	if _cod_agente IN ("02015") then  
		let _cod_agente = "00125";													
	end if
	-- Unificar ducruet david A ducruet
	if _cod_agente IN ("02154",'02904') then  
		let _cod_agente = "00035";													
	end if
	--Unificar seg centralizados chiriqui, chitre, colon, santiago, aguadulce A seguros centralizados
	if _cod_agente IN ("01745","01743","01744","01751","01851") then  
		let _cod_agente = "00166";													
	end if	
	-- Unificar grupo de seguros tempus chitre A grupo de seguros tempus
	if _cod_agente IN ("02081") then  
		let _cod_agente = "00474";													
	end if
	-- Unificar  lideres en seg santiago A Lideres en seguros
	if _cod_agente IN ("01990") then  
		let _cod_agente = "01009";													
	end if
	-- Unificar B&G insurance group chitre A B&G insurance group, s.a.
	if _cod_agente IN ("02103") then  
		let _cod_agente = "01670";													
	end if
	-- Unificar SH ASESORES DE SEGUROS(01898) con sh asesores de seg chorrera(02196)
	if _cod_agente in("02196") then
		let _cod_agente = "01898";
	end if
	-- Unificar Maria Eugenia de la guardia. A Gonzalez de la guardia y asociados
	if _cod_agente IN ("00197") then  
		let _cod_agente = "00291";													
	end if
	
	-- Unificar Leysa Rodriguez(01904) Dalys de Rodriguez(00138) Mireya de Malo(01867) Sandra Caparroso(00965) con D.R. ASESORES DE SEGUROS(00011)
	if _cod_agente in("01904","00138","01867","00965") then
		let _cod_agente = "00011";
	end if
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Daysi de la Rosa(01948) con Corredores de Seguros de la Rosa(02208)
	if _cod_agente in("01948") then
		let _cod_agente = "02208";
	end if
	if _cod_agente in("01779") then
		let _cod_agente = "02229";
	end if	
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Asegure Corredor de Seguros(02102) con Lynette Lopez Arango(00817)
	if _cod_agente in("02102") then
		let _cod_agente = "00817";
	end if
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Asegure Corredor de Seguros(00517) con J2L Asesores(01440)
	if _cod_agente in("00517") then
		let _cod_agente = "01440";
	end if

	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Hugo Caicedo (00525) con Blue Sea Insurance Brokers, Corp.(00779)
	if _cod_agente in("00525") then
		let _cod_agente = "00779";
	end if
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Abdiel Teran Della Togna (00076) con Conjuga Insurance Solutions(02119)
	if _cod_agente in("00076") then
		let _cod_agente = "02119";
	end if

	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Ureña y Ureña (00050) con Edgar Alberto Ureña Romero(00845)
	if _cod_agente in("00050") then
		let _cod_agente = "00845";
	end if
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Seguros y Asesoria Maritima (01916) con Roderick Subia(00793)
	if _cod_agente in("01916") then
		let _cod_agente = "00793";
	end if
	
	-- Solicitud de Leticia del 20/02/2015
	-- Unificar Carlos Manuel Mendez (00104) Carlos Manuel Mendez Dutari (02037) con Marcha Seguros, S.A.(00119)
	if _cod_agente in("00104","02037") then
		let _cod_agente = "00119";
	end if	
	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	 select nombre
	   into _n_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;
	  
	  if _cod_ramo in('004','020') then
		let _cantidad_pol = 0;
	  end if
       
      select count(*)
	    into _cnnt
		from tropical2
	   where cod_agente    = _cod_agente
         and no_documento  = _no_documento;
		 
	  if _cnnt = 0 then
		 
		INSERT INTO tropical2(
		cod_agente,
		prima_cobrada2010,
		prima_cobrada_nva,
		cantidad_polizas,
		no_documento,
		n_agente,
		n_ramo,
		categoria,
		pri_co_nva_ap 
		)
		VALUES(
		_cod_agente,
		0,
		_monto_p,
		_cantidad_pol,
		_no_documento,
		_n_agente,
		_n_ramo,
		_categoria,
		_prima_suscrita
		);
	  else
		update tropical2
		   set prima_cobrada_nva = prima_cobrada_nva + _monto_p
		 where cod_agente        = _cod_agente
		   and no_documento  = _no_documento;
      end if	  

end foreach

let _valor = sp_che206zz();

let _prima_cob2014 = 0;
let _prima_cob_nva = 0;
let _cnt_pol       = 0;

foreach
	select cod_agente,
	       categoria,
		   sum(prima_cobrada2010),
		   sum(prima_cobrada_nva),
		   sum(cantidad_polizas)
	  into _cod_agente,
           _categoria,
		   _prima_cob2014,
		   _prima_cob_nva,
		   _cnt_pol
	from tropical2
	group by cod_agente,categoria
	order by categoria,cod_agente

	let _fecha_aplico = null;
	select fecha_aplico
	  into _fecha_aplico
	  from tropical
	 where cod_agente = _cod_agente;

	if _fecha_aplico is null then 
		if _cnt_pol >= 40 then
            if _categoria = 1 and _prima_cob2014 > 100000 and _prima_cob_nva >= 50000 then
				update tropical
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria;

				update tropical2
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria
				   and no_documento is null;				 
			end if
            if _categoria = 2 and _prima_cob2014 > 50000 and _prima_cob_nva >= 25000 then
				update tropical
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria;
				   
				update tropical2
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria
				   and no_documento is null;
			end if
            if _categoria = 3 and _prima_cob2014 < 49999 and _prima_cob_nva >= 15000 then
				update tropical
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria;
				   
				update tropical2
				   set fecha_aplico = current
				 where cod_agente   = _cod_agente
				   and categoria    = _categoria
				   and no_documento is null;				 
			end if
		end if	
                				 
    end if            			
	
end foreach

update tropical2
   set pri_co_nva_ap = 0
 where no_documento is null;

DROP TABLE tmp_tropi;

return 0;

END PROCEDURE;






