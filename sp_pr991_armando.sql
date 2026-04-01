-- Procedimiento que genera los Estados de Cuenta de Reaseguro
-- Creado    : 07/10/2009 - Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	  d_prod_sp_pr991_crit    
-- execute procedure sp_pr991("001","2012-04","2012-06","063;","1")

drop procedure sp_pr991;
create procedure sp_pr991(
a_compania	char(03),
a_periodo1	char(07),
a_periodo2	char(07),
a_agente	char(255)	default "*",
a_tipo		char(2)		default "01")
returning	char(7),
			char(7),
			smallint,
			char(50),
			char(50),
			date,
			char(255),
			char(255),
			dec(16,2),
			dec(16,2),
			char(10),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			smallint,
			char(100),
			date,char(3);
begin

define _concepto_r			varchar(80);
define s_des_cod_clase		char(255);
define i_concepto1			char(255);
define i_concepto2			char(255);
define m_concepto1			char(255);
define m_concepto2			char(255);
define v_filtros			char(255);
define _obs					char(255);
define s_desc_contrato		char(70);
define t_reasegurador		char(50);
define _nom_contrato		char(50);
define s_des_clase			char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define m_contrato			char(50);
define f_no_documento		char(20);
define v_no_documento		char(20);
define s_usuario			char(15); 
define _obsp				char(14);
define _porc				char(14);
define s_cuenta				char(12); 
define f_no_poliza			char(10);
define v_no_poliza			char(10);
define s_fechastr			char(10);
define _no_remesa			char(10);
define t_moneda				char(10);
define t_tipo				char(10);
define s_tipo				char(10);
define _anio_reas			char(9);
define v_cod_clase			char(3);
define _cod_contrato		char(5);
define i_periodo1			char(7);
define i_periodo2			char(7);
define m_periodo1			char(7);
define m_periodo2			char(7);
define s_periodo			char(7);
define i_cod_contrato		char(5);
define s_cod_contrato		char(5);
define v_no_endoso			char(5);
define v_no_unidad			char(5);
define f_no_endoso			char(5);
define i_no_unidad			char(5);
define i_cod_ruta			char(5);	
define i_contrato			char(5);
define f_unidad				char(5);
define s_ano				char(4); 
define _trimestre_char		char(3);
define v_cod_cober_reas		char(3);
define i_cod_cober_reas		char(3);
define s_cod_cobertura		char(3);
define i_reasegurador		char(3);
define s_cod_coasegur		char(3);
define m_reasegurador		char(3);
define s_cod_clase			char(3);  
define c_cod_clase			char(3);
define v_cod_ramo			char(3);
define f_cod_ramo			char(3);
define i_cod_ramo			char(3);
define c_cod_ramo			char(3);
define s_ccosto				char(3); 
define v_clase				char(3);  
define m_moneda				char(2);
define i_moneda				char(2);
define i_tipo_contrato		char(1);
define _tipo				char(1);
define s_porc_partic_prima	dec(10,4);
define i_porc_prima			dec(10,4);
define i_porc_suma			dec(10,4);
define v_prima_suscrita		dec(16,2);
define e_prima_suscrita		dec(16,2);
define f_prima_suscrita		dec(16,2);
define i_suma_asegurada		dec(16,2);
define i_saldo_favor		dec(16,2);
define i_saldo_final		dec(16,2);
define f_prima_eduni		dec(16,2);
define _dif_redondeo		dec(16,2);
define m_saldo_favor		dec(16,2);
define m_saldo_final		dec(16,2);
define q_facuni_xuni		dec(16,2);
define f_p_emifacon			dec(16,2);
define f_diferencia			dec(16,2);
define f_prima_dfac			dec(16,2);
define v_prima_det			dec(16,2);
define s_inicioano			dec(16,2);
define s_siniestro			dec(16,2);
define v_prima_enc			dec(16,2);
define s_comision			dec(16,2);
define s_impuesto			dec(16,2);
define _acumulado			dec(16,2);
define i_total_db			dec(16,2);
define i_total_cr			dec(16,2);
define _q_endeuni			dec(16,2);
define s_p_partic			dec(16,2);
define s_credito			dec(16,2);
define _q_facuni			dec(16,2);
define s_debito				dec(16,2);
define m_valor				dec(16,2);
define eu_total				dec(16,2);
define ef_total				dec(16,2);
define i_haber				dec(16,2);
define v_prima				dec(16,2);
define i_debe				dec(16,2);
define m_debe				dec(16,2);
define m_haber				dec(16,2);
define m_total_db			dec(16,2);
define m_total_cr			dec(16,2);
define m_p_partic			dec(16,2);
define m_seleccionado		smallint;
define _porc_partic			smallint;
define i_no_cambio			smallint;
define _cnt_saber			smallint;
define _tipo_cont			smallint;
define _trim_reas			smallint;
define i_renglon		   	smallint;
define v_renglon			smallint;
define s_renglon			smallint;
define m_renglon			smallint;
define _realizar			smallint;
define f_ns100				smallint;
define _tipo2				smallint;
define _rengl				smallint;
define _saber				smallint;
define li_si				smallint;
define f_hay				smallint;
define i_orden_ult			integer;
define i_serie				integer;
define i_orden				integer;
define _fecha_transf		date;
define s_fecha_rep			date;
define m_fecha				date;
define s_fecha				date;
define i_fecha		   		date;
define _descrip             varchar(100);

set isolation to dirty read;

delete from reaestcta
 where periodo1 = a_periodo1
   and periodo2 = a_periodo2;

let v_descr_cia     = sp_sis01(a_compania);
let s_des_clase	    = "";	
let s_desc_contrato	= "";
let v_cod_ramo      = "";
let s_comision		= 0;
let s_impuesto		= 0;
let s_siniestro		= 0;
let _concepto_r     = "";
let t_reasegurador  = "";
let v_clase = '' ;

--set debug file to "sp_pr991.trc";	
--trace on;

create temp table tmp_xramo(
periodo1		char(7),
periodo2		char(7),
cod_ramo		char(3),
reasegurador	char(3),
contrato		char(10),			   
p_partic		dec(16,2),
monto			dec(16,2),
renglon			smallint,
tipo			char(10),
cod_clase		char(3),
fecha_transf	date,
no_remesa		char(10));
create index id1_tmp_xramo on tmp_xramo(periodo1,periodo2,cod_ramo,cod_clase,reasegurador,contrato,p_partic,renglon);

-- saldos iniciales de reaseguro
let s_fecha_rep = sp_sis36(a_periodo2) ;
let c_cod_clase = 0 ;
let c_cod_ramo  = 0 ;
let s_renglon   = 0 ;
let s_debito    = 0;

if a_tipo = "01" then 
   let s_tipo =	"Bouquet";
elif a_tipo = "02" then 
   let s_tipo =	"Runoff";
elif a_tipo = "03" then 
   let s_tipo =	"50%Mapfre";
elif a_tipo = "06" then 
   let s_tipo =	"Facilidad CAR";
elif a_tipo = "08" then 
   let s_tipo =	"Cuota Parte / Vida y Acc. P.";
elif a_tipo = "04" then
   let s_tipo = "Facultativo";
elif a_tipo = "09" then 
   let s_tipo =	"Bouquet-Fianzas";
elif a_tipo = "10" then 
   let s_tipo =	"Auto-Casco";
end if

select cod_contrato,
	   nombre,
	   nombre,
	   tipo
  into a_tipo,
	   s_tipo,
	   m_contrato,
	   _tipo2
  from reacontr
 where activo = 1
   and cod_contrato = a_tipo;

call sp_rea002(a_periodo2,_tipo2) returning _anio_reas,_trim_reas;

if _trim_reas = 1 then
	let _trimestre_char = '1ER';
elif _trim_reas = 2 then
	let _trimestre_char = '2DO';
elif _trim_reas = 3 then
	let _trimestre_char = '3ER';
else
	let _trimestre_char = '4TO';
end if

foreach
	select reasegurador,
	       saldo_inicial
	  into s_cod_coasegur,
	       s_credito 
	  from reaestct1 
	 where ano       = _anio_reas  
	   and trimestre = _trim_reas 	
	   and contrato  = a_tipo

	let s_fecha = current;
	let s_fecha = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;
	let c_cod_clase = 0;

	if s_credito is null then
	   let s_credito =	0;
	end if

	select max(renglon)
	  into s_renglon
	  from reaestcta
	 where periodo1     = a_periodo1
	   and periodo2     = a_periodo2
	   and reasegurador = s_cod_coasegur
	   and contrato     = s_tipo;

	if s_renglon is null then
	   let s_renglon =	0 ;
	end if

	let s_renglon =	s_renglon + 1;
	let _concepto_r = 'SALDO ANTERIOR';

	if a_tipo = "02" and s_cod_coasegur = '055' then --solo para cooper gay
		let _concepto_r = _concepto_r || " CORRESPONDE A:70% PART. DE MAPFRE, Y 30% A TRANSRECO";
	end if

	if a_tipo = '04' then
		if s_credito < 0 then
			let s_debito = abs(s_credito);
			let s_credito = 0;
		else
			let s_debito = 0;
			let s_credito = abs(s_credito);
		end if 
	end if 

	insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
	values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,null,_concepto_r,s_debito,s_credito,"01",0,0,0,0,0,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
end foreach

if a_tipo = "04" then --Facultativo
	let _saber = 0;
	
	foreach
		select cod_coasegur,
		       sum(p_partic),
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
		       sum(prima),
		       sum(comision),
		       sum(impuesto),
		       sum(siniestro)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito,
			   s_comision,
			   s_impuesto,
			   s_siniestro
		  from reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		 group by cod_coasegur,cod_clase,cod_contrato,cod_ramo
		 order by cod_coasegur,cod_clase,cod_contrato,cod_ramo

		let s_debito = 0;
		let _saber = 1;
		
		if s_debito is null then
		   let s_debito = 0;
		end if
		
		if s_credito is null then
		   let s_credito = 0;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
	       and reasegurador = s_cod_coasegur
	       and contrato     = s_tipo;

		if s_renglon is null then
		   let s_renglon =	0 ;
		end if

		if  s_renglon =	0 then
			let s_fecha = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

			insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			values (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;
			
			let s_renglon = 1;			
		end if

		foreach
			select trim(nombre),
				   renglon
			  into s_des_cod_clase,
				   _rengl
			  from reaestdif
		     where contrato = a_tipo

			let s_renglon =	s_renglon + 1;
			let s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   let s_cod_contrato =	"";
			end if

			select trim(nombre),
				   trim(desc_contrato) 
			  into s_des_clase,
				   s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

		    let s_debito =	0;

			if _rengl = 2 then
			   let s_credito = s_comision;
			elif _rengl = 3 then
			   let s_credito = s_impuesto;
            elif _rengl = 4 then
			   let s_credito = s_siniestro;
			end if

			if _rengl in(2,3,4) then

			    if s_credito < 0 then 
				   let s_debito  =	0;
			    else
				   let s_debito  = s_credito;
				   let s_credito = 0;
			    end if
			else

				if s_credito < 0 then 
				   let s_debito  =	-1 * s_credito;
				   let s_credito = 0;
				end if
			end if

	 		let c_cod_clase = s_cod_clase;

			insert into reaestcta(periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,_rengl,s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
		end foreach
	end foreach
	
--	if _saber = 0 then

	foreach
		select no_remesa,
			   cod_coasegur,
			   tipo,
			   monto
		  into _no_remesa,
			   s_cod_coasegur,
			   t_tipo,
			   s_credito
		  from reatrx1
		 where cod_contrato = a_tipo
		   and periodo between a_periodo1 and a_periodo2
		  -- and actualizado  = 1
		
		let _cnt_saber = 0;
		
		select count(*)
		  into _cnt_saber
		  from reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		   and cod_coasegur = s_cod_coasegur;
		
		if _cnt_saber is null then
			let _cnt_saber = 0;
		end if
		
		if _cnt_saber <> 0 then
			continue foreach;
		end if
		
		foreach
			select cod_ramo
			  into s_cod_clase
			  from reatrx2
			 where no_remesa = _no_remesa

			exit foreach;
		end foreach

		select fecha_transf
		  into _fecha_transf
		  from reatrx1
		 where no_remesa = _no_remesa;

		if s_cod_clase = '001' then 
			 let v_clase = '1' ;
		end if
		if s_cod_clase = '002' or v_cod_ramo = '003' then 
			 let v_clase = '2' ;
		end if					
		if s_cod_clase = '004' then --'010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
			 let v_clase = '4' ;
		end if
		if s_cod_clase = '005' then  --005
			 let v_clase = '5' ;
		end if
		if s_cod_clase = '006' then --004
			 let v_clase = '6' ;
		end if
		if s_cod_clase = '007' then --019
			 let v_clase = '7' ;
		end if
		if s_cod_clase = '008' then --008
			 let v_clase = '8' ;
		end if
		if s_cod_clase = '009' then --009
			 let v_clase = '9' ;
		end if
		if s_cod_clase = '010' then --009
			 let v_clase = '10' ;
		end if
		if s_cod_clase = '011' then --016
			 let v_clase = '11' ;
		end if
		if s_cod_clase = '012' then --016
			 let v_clase = '12' ;
		end if
		if s_cod_clase = '013' then	--auto casco
			 let v_clase = '13' ;
		end if

		let s_renglon   = s_renglon + 1 ;
		let c_cod_clase = v_clase ;
		let c_cod_ramo  = s_cod_clase ;

		insert into tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo,cod_clase,fecha_transf,no_remesa)
		values (a_periodo1,a_periodo2,c_cod_ramo,s_cod_coasegur,s_tipo,0,s_credito,s_renglon,t_tipo,c_cod_clase,_fecha_transf,_no_remesa);
	end foreach
end if
 
if a_tipo = "03" or a_tipo = "02" then --50%mapfre-runoff
	let s_renglon =	0 ;
	let s_debito  =	0 ;
	let s_credito =	0 ;

	foreach
		select cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
		       sum(participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  from reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
	  group by cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
		       cod_ramo
	  order by cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
		       cod_ramo

			let s_debito =	0;

			if s_debito is null then
			   let s_debito =	0;
			end if
			if s_credito is null then
			   let s_credito =	0;
			end if

			select max(renglon)
			  into s_renglon
			  from reaestcta
			 where periodo1     = a_periodo1
			   and periodo2     = a_periodo2
		       and reasegurador = s_cod_coasegur
		       and p_partic     = s_p_partic	
		       and contrato     = s_tipo;

			if s_renglon is null then
			   let s_renglon =	0 ;
			end if

			let _concepto_r = 'SALDO ANTERIOR';

			if  s_renglon =	0 then
				let s_fecha = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

				insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
				values (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"",_concepto_r,0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0');
				 let s_renglon = 1;
			end if

			let s_renglon =	s_renglon + 1;
			let s_fecha = sp_sis36(a_periodo2);

			if s_cod_contrato is null then
			   let s_cod_contrato =	"";
			end if

			select trim(nombre),
				   trim(desc_contrato) 
			  into s_des_clase,
				   s_desc_contrato
			  from rearamo 
		     where ramo_reas = s_cod_clase;

			let s_des_cod_clase = 'Saldo Cuenta Tecnica '|| _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

			if s_credito < 0 then 
			   let s_debito  =	-1 * s_credito ;
			   let s_credito = 0;
			end if

     		let c_cod_clase = s_cod_clase ;

			insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
	end foreach
end if

if a_tipo = "08" then --cuota parte acc y vida
	let s_renglon =	0 ;
	let s_debito  =	0 ;
	let s_credito =	0 ;

	foreach
		select cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
			   desc_contrato,
		       sum(participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
			   _cod_contrato,
	   	       s_credito
		  from reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		 group by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo,desc_contrato
		 order by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo,desc_contrato

		let s_debito =	0;

		if s_debito is null then
		   let s_debito =	0;
		end if

		if s_credito is null then
		   let s_credito =	0;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
		   and reasegurador = s_cod_coasegur
		   and p_partic     = s_p_partic	
		   and contrato     = s_tipo;

		if s_renglon is null then
		   let s_renglon =	0 ;
		end if

		let _concepto_r = 'SALDO ANTERIOR';

		if  s_renglon =	0 then
			let s_fecha = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1;

			insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			values (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"",_concepto_r,0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0');

			let s_renglon = 1;
		end if

		let s_renglon =	s_renglon + 1;
		let s_fecha = sp_sis36(a_periodo2);

		if s_cod_contrato is null then
		   let s_cod_contrato =	"";
		end if

		select trim(nombre),
			   trim(desc_contrato) 
		  into s_des_clase,
			   s_desc_contrato
		  from rearamo 
		 where ramo_reas = s_cod_clase;

		select tipo_contrato
		  into _tipo_cont
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_cont = 1 then
			let _nom_contrato = 'RETENCION';
		elif _tipo_cont = 3 then
			let _nom_contrato = 'FACULTATIVO';
		elif _tipo_cont = 5 then
			let _nom_contrato = 'CUOTA PARTE';
		elif _tipo_cont = 7 then
			let _nom_contrato = 'EXCEDENTE';
		end if

		let s_des_cod_clase = 'Saldo Cuenta Tecnica '|| _trimestre_char || ' Trimestre' || '   ' || _anio_reas || ' ' || trim(_nom_contrato);

		if s_credito < 0 then 
		   let s_debito  =	-1 * s_credito ;
		   let s_credito = 0;
		end if

		let c_cod_clase = s_cod_clase ;

		insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
	end foreach
end if
if a_tipo = "01" or a_tipo = '10' then --Bouquet
	
	if a_tipo = '10' then --Preguntar a Armando (Caso es 100% Participacion)
		let _porc_partic = 101;
	else
		let _porc_partic = 100;
	end if

	let s_renglon =	0;
	let s_debito  =	0;
	let s_credito =	0;
	-- participacion de reaseguro
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,012,014),
	--                 5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]
	FOREACH
		SELECT cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
		       sum(participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  FROM reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		   and p_partic  < _porc_partic--100
		 group by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo
		 order by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo

		let s_debito =	0 ;

		if s_debito is null then
		   LET s_debito =	0 ;
		end if
		if s_credito is null then
		   LET s_credito =	0 ;
		end if

		--LET s_p_partic = 50;

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
		   and reasegurador = s_cod_coasegur
		   and p_partic     = s_p_partic	
		   and contrato     = s_tipo ;

		if s_renglon is null then
		   LET s_renglon =	0 ;
		end if

		if  s_renglon =	0 then
			LET s_fecha = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1 ;

			INSERT INTO reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,Total_db,Total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			VALUES (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;

			LET s_renglon = 1;
		end if

		LET s_renglon =	s_renglon + 1;
		LET s_fecha = sp_sis36(a_periodo2);

		if s_cod_contrato is null then
		   let s_cod_contrato =	"";
		end if

		select trim(nombre),
			   trim(desc_contrato) 
		  into s_des_clase,s_desc_contrato
		  from rearamo 
		 where ramo_reas = s_cod_clase;

		let s_des_cod_clase = 'Saldo Cuenta Tecnica ' || _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

		if s_credito < 0 then 
		   let s_debito  =	-1 * s_credito ;
		   let s_credito = 0;
		end if

		let c_cod_clase = s_cod_clase ;

		insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;
	end foreach

elif a_tipo = "06" or a_tipo = '09' then --Facilidad CAR, BOUQUET FIANZAS
	let s_renglon =	0 ;
	let s_debito  =	0 ;
	let s_credito =	0 ;
	let _saber    = 0;

	foreach
		select cod_coasegur,
		       p_partic,
		       cod_clase,
		       cod_contrato,
			   cod_ramo,
		       sum(participar)
		  into s_cod_coasegur, 
			   s_p_partic, 
			   s_cod_clase,
			   s_cod_contrato,
			   c_cod_ramo,
	   	       s_credito
		  from reacoest
		 where anio      = _anio_reas
		   and trimestre = _trim_reas
		   and borderaux = a_tipo
		 group by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo
		 order by cod_coasegur,p_partic,cod_clase,cod_contrato,cod_ramo

		let s_debito =	0 ;
		let _saber = 1;

		if s_debito is null then
		   let s_debito =	0 ;
		end if
		if s_credito is null then
		   let s_credito =	0 ;
		end if

		--LET s_p_partic = 50;

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1 = a_periodo1
		   and periodo2 = a_periodo2
		   and reasegurador = s_cod_coasegur
		   and p_partic = s_p_partic	
		   and contrato = s_tipo ;

		if s_renglon is null then
		   let s_renglon =	0 ;
		end if

		if  s_renglon =	0 then
			let s_fecha = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]) - 1 ;

			insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
			values (a_periodo1,a_periodo2,1,s_cod_coasegur,s_tipo,s_fecha,"","Saldo Anterior",0.00,0.00,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,'0','0') ;

			let s_renglon = 1;
		end if

		let s_renglon =	s_renglon + 1;
		let s_fecha = sp_sis36(a_periodo2);

		if s_cod_contrato is null then
		   let s_cod_contrato =	"";
		end if

		select trim(nombre),
			   trim(desc_contrato) 
		  into s_des_clase,
			   s_desc_contrato
		  from rearamo 
		 where ramo_reas = s_cod_clase;

		let s_des_cod_clase = 'Saldo Cuenta Tecnica ' || _trimestre_char || ' Trimestre' || '   ' || _anio_reas;

		if s_credito < 0 then 
		   let s_debito  =	-1 * s_credito ;
		   let s_credito = 0;
		end if

		let c_cod_clase = s_cod_clase ;

		insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase) ;

	end foreach

    if _saber = 0 then

		foreach
			select no_remesa,
				   tipo,
				   monto
			  into _no_remesa,
				   t_tipo,
				   s_credito
			  from reatrx1
			 where cod_contrato = a_tipo
			   and periodo between a_periodo1 and a_periodo2 
			   and cod_coasegur = s_cod_coasegur
			  -- and actualizado  = 1

			foreach
				select cod_ramo
				  into s_cod_clase
				  from reatrx2
				 where no_remesa = _no_remesa

				exit foreach;
			end foreach

			select fecha_transf
			  into _fecha_transf
			  from reatrx1
			 where no_remesa = _no_remesa;

			if s_cod_clase = '001' then 
				 let v_clase = '1' ;
			end if
			if s_cod_clase = '002' or v_cod_ramo = '003' then 
				 let v_clase = '2' ;
			end if					
			if s_cod_clase = '004' then --'010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
				 let v_clase = '4' ;
			end if
			if s_cod_clase = '005' then  --005
				 let v_clase = '5' ;
			end if
			if s_cod_clase = '006' then --004
				 let v_clase = '6' ;
			end if
			if s_cod_clase = '007' then --019
				 let v_clase = '7' ;
			end if
			if s_cod_clase = '008' then --008
				 let v_clase = '8' ;
			end if
			if s_cod_clase = '009' then --009
				 let v_clase = '9' ;
			end if
			if s_cod_clase = '010' then --009
				 let v_clase = '10' ;
			end if
			if s_cod_clase = '011' then --016
				 let v_clase = '11' ;
			end if
			if s_cod_clase = '012' then --016
				 let v_clase = '12' ;
			end if
			if s_cod_clase = '013' then	--Auto casco
				 let v_clase = '13' ;
			end if

			let s_renglon   = s_renglon + 1 ;
			let c_cod_clase = v_clase ;
			let c_cod_ramo  = s_cod_clase ;

			insert into tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo,cod_clase,fecha_transf,no_remesa)
			values (a_periodo1,a_periodo2,c_cod_ramo,s_cod_coasegur,s_tipo,0,s_credito,s_renglon,t_tipo,c_cod_clase,_fecha_transf,_no_remesa);
		end foreach
   end if
end if
	-- Carga de transacciones x tipo 
	-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014), 
	--                 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)] 

let s_renglon =	0 ;
let s_debito =	0 ;
let s_credito =	0 ;
let v_clase = '' ;

foreach
	select cod_coasegur
	  into s_cod_coasegur
	  from reacoest
	 where anio      = _anio_reas
	   and trimestre = _trim_reas
	   and borderaux = a_tipo
	 group by cod_coasegur
	 order by cod_coasegur

	foreach
		select p_partic
		  into s_p_partic
		  from reacoest
		 where anio         = _anio_reas
		   and trimestre    = _trim_reas
		   and borderaux    = a_tipo
		   and cod_coasegur = s_cod_coasegur
		exit foreach;
	end foreach

	foreach
		select no_remesa,
			   tipo,
			   monto
		  into _no_remesa,
			   t_tipo,
			   s_credito
		  from reatrx1
		 where cod_contrato = a_tipo
		   and periodo between a_periodo1 and a_periodo2 
		   and cod_coasegur = s_cod_coasegur
		  -- and actualizado  = 1

		foreach
			select cod_ramo
			  into s_cod_clase
			  from reatrx2
			 where no_remesa = _no_remesa

			exit foreach;
		end foreach

		select fecha_transf
		  into _fecha_transf
		  from reatrx1
		 where no_remesa = _no_remesa;

		if s_cod_clase = '001' then 
			 let v_clase = '1' ;
		end if
		if s_cod_clase = '002' or v_cod_ramo = '003' then 
			 let v_clase = '2' ;
		end if					
		if s_cod_clase = '004' then --'010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
			 let v_clase = '4' ;
		end if
		if s_cod_clase = '005' then  --005
			 let v_clase = '5' ;
		end if
		if s_cod_clase = '006' then --004
			 let v_clase = '6' ;
		end if
		if s_cod_clase = '007' then --019
			 let v_clase = '7' ;
		end if
		if s_cod_clase = '008' then --008
			 let v_clase = '8' ;
		end if
		if s_cod_clase = '009' then --009
			 let v_clase = '9' ;
		end if
		if s_cod_clase = '010' then --009
			 let v_clase = '10' ;
		end if
		if s_cod_clase = '011' then --016
			 let v_clase = '11' ;
		end if
		if s_cod_clase = '012' then --016
			 let v_clase = '12' ;
		end if
		if s_cod_clase = '010' then --009
			 let v_clase = '10' ;
		end if
		if s_cod_clase = '013' then	--Auto casco
			 let v_clase = '13' ;
		end if

		let s_renglon   = s_renglon + 1 ;
		let c_cod_clase = v_clase ;
		let c_cod_ramo  = s_cod_clase ;

		insert into tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo,cod_clase,fecha_transf,no_remesa)
		values (a_periodo1,a_periodo2,c_cod_ramo,s_cod_coasegur,s_tipo,s_p_partic,s_credito,s_renglon,t_tipo,c_cod_clase,_fecha_transf,_no_remesa);
	end foreach
end foreach

foreach
	select reasegurador
	  into s_cod_coasegur
	  from reaestct1
	 where ano       = _anio_reas
	   and trimestre = _trim_reas
	   and contrato  = a_tipo
       and reasegurador not in(select cod_coasegur 
								 from reacoest
								where anio      = _anio_reas
								  and trimestre = _trim_reas
								  and contrato  = a_tipo)

	foreach
	    select no_remesa,
	           tipo,
	           monto
	      into _no_remesa,
	           t_tipo,
	           s_credito
	      from reatrx1
	     where cod_contrato = a_tipo
	       and periodo between a_periodo1 and a_periodo2 
		   and cod_coasegur = s_cod_coasegur
		  -- and actualizado  = 1

		foreach
			select cod_ramo
			  into s_cod_clase
			  from reatrx2
			 where no_remesa = _no_remesa

			exit foreach;
		end foreach

		select fecha_transf
		  into _fecha_transf
		  from reatrx1
		 where no_remesa = _no_remesa;

		if s_cod_clase = '001' then 
			 let v_clase = '1' ;
		end if
		if s_cod_clase = '002' or v_cod_ramo = '003' then 
			 let v_clase = '2' ;
		end if					
		if s_cod_clase = '004' then --'010' or v_cod_ramo = '011' or v_cod_ramo = '012'  or v_cod_ramo = '014' then 
			 let v_clase = '4' ;
		end if
		if s_cod_clase = '005' then  --005
			 let v_clase = '5' ;
		end if
		if s_cod_clase = '006' then --004
			 let v_clase = '6' ;
		end if
		if s_cod_clase = '007' then --019
			 let v_clase = '7' ;
		end if
		if s_cod_clase = '008' then --008
			 let v_clase = '8' ;
		end if
		if s_cod_clase = '009' then --009
			 let v_clase = '9' ;
		end if
		if s_cod_clase = '010' then --009
			 let v_clase = '10' ;
		end if
		if s_cod_clase = '011' then --016
			 let v_clase = '11' ;
		end if
		if s_cod_clase = '012' then --016
			 let v_clase = '12' ;
		end if
		if s_cod_clase = '013' then	--Auto casco
			 let v_clase = '13' ;
		end if

		let s_renglon   = s_renglon + 1 ;
		let c_cod_clase = v_clase ;
		let c_cod_ramo  = s_cod_clase ;

		insert into tmp_xramo (periodo1,periodo2,cod_ramo,reasegurador,contrato,p_partic,monto,renglon,tipo,cod_clase,fecha_transf,no_remesa)
		values (a_periodo1,a_periodo2,c_cod_ramo,s_cod_coasegur,s_tipo,0,s_credito,s_renglon,t_tipo,c_cod_clase,_fecha_transf,_no_remesa);

	end foreach
end foreach

foreach
		select distinct reasegurador,
			   p_partic,
			   tipo,
			   cod_ramo,
			   cod_clase,
			   fecha_transf,
			   monto,
			   no_remesa
		  into s_cod_coasegur,
			   s_p_partic,
			   t_tipo,
			   c_cod_ramo,
			   c_cod_clase,
			   s_fecha,
			   s_credito,
			   _no_remesa
		  from tmp_xramo

		let s_debito =	0 ;

		if s_debito is null then
		   let s_debito =	0 ;
		end if

		if s_credito is null then
		   let s_credito =	0 ;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestcta
		 where periodo1     = a_periodo1
		   and periodo2     = a_periodo2
		   and reasegurador = s_cod_coasegur
		   and p_partic     = s_p_partic	
		   and contrato     = s_tipo ;

		if s_renglon is null then
		   let s_renglon =	0 ;
		end if

		let s_renglon =	s_renglon + 1 ;

		if s_credito < 0 then 
		   let s_debito  =	-1 * s_credito ;
		   let s_credito =	0 ;				   
		end if
		if s_credito < 0 then 
		   let s_debito  =	-1 * s_credito ;
		   let s_credito =	0 ;
		end if
		let _descrip = ''; 
		select descrip
		  into _descrip
		  from reatrx1
		 where no_remesa = _no_remesa;
		 
		if t_tipo = "01" then
			--let s_des_cod_clase = "Remesa Enviada Al Reasegurador - " || _no_remesa;
			 let s_des_cod_clase = trim(_descrip) || " " || _no_remesa;
		elif t_tipo = "02" then
			 --let s_des_cod_clase = "Remesa Recibida del Reasegurador - " || _no_remesa;
			 let s_des_cod_clase = trim(_descrip) || " " || _no_remesa;
		else
			select descrip
			  into s_des_cod_clase
			  from reatrx1
			 where no_remesa = _no_remesa;					
			LET s_des_cod_clase = trim(s_des_cod_clase) || " " || _no_remesa;
		end if

		insert into reaestcta (periodo1,periodo2,renglon,reasegurador,contrato,fecha,concepto1,concepto2,debe,haber,moneda,saldo_favor,saldo_final,total_db,total_cr,p_partic,seleccionado,fecha_rep,cod_ramo,cod_clase)
		values (a_periodo1,a_periodo2,s_renglon,s_cod_coasegur,s_tipo,s_fecha,"",s_des_cod_clase,s_debito,s_credito,"01",0,0,0,0,s_p_partic,1,s_fecha_rep,c_cod_ramo,c_cod_clase);
end foreach

-- procesos v_filtros
let v_filtros ="";
if a_agente <> "*" then
	let v_filtros = trim(v_filtros) ||"Reasegurador "||trim(a_agente) ;
	let _tipo = sp_sis04(a_agente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update reaestcta
	       set seleccionado = 0
	     where seleccionado = 1
	       and reasegurador not in (select codigo from tmp_codigos);
	else
		update reaestcta
	       set seleccionado = 0
	     where seleccionado = 1
	       and reasegurador in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

foreach
	select periodo1,
		   periodo2,
		   renglon,
		   moneda
	  into m_periodo1,
		   m_periodo2,
		   m_renglon,
		   m_moneda
	  from reaestcta
	 where periodo1 = a_periodo1
	   and periodo2 = a_periodo2
	   and seleccionado in (1)
	exit foreach;
end foreach

foreach
	select reasegurador,
		   concepto1,
		   concepto2,
		   sum(debe),
		   sum(haber),
		   fecha
	  into m_reasegurador,
		   m_concepto1,
		   m_concepto2,
		   m_debe,
		   m_haber,
		   m_fecha
	  from reaestcta
	 where periodo1 = a_periodo1
	   and periodo2 = a_periodo2
	   and seleccionado in(1)
	 group by reasegurador,concepto1,concepto2,fecha
	 order by reasegurador,concepto2,fecha

	if m_moneda = "01" then
		let t_moneda = "Dolares";
	end if

    if m_debe = 0 and m_haber = 0 then
    	continue foreach;
    end if

	let m_valor = 0;

	if a_tipo = '04' then
		if trim(m_concepto1) = '2' or trim(m_concepto1) = '3' then	--comision
			if m_haber < 0 then
				let m_haber = m_haber * -1;
			end if
		elif trim(m_concepto1) = '4' then
			if m_haber < 0 then
				let m_haber = m_haber * -1;
			end if
		end if
	end if

	let m_valor = m_debe - m_haber;

	if m_valor < 0 then
	   let m_haber = ABS(m_valor);
	   let m_debe = 0;
	else
	   let m_debe  = ABS(m_valor);
	   let m_haber = 0;
	end if

	select nombre
	  into t_reasegurador
	  from emicoase
	 where cod_coasegur = m_reasegurador;
	return  m_periodo1,	   
			m_periodo2,	   
			m_renglon,	   
			t_reasegurador,
			m_contrato,	   
			m_fecha,	   
			m_concepto1,   
			m_concepto2,   
			m_debe,		   
			m_haber,	   
			t_moneda,	   
			0,			   
			0,			   
			0,			   
			0,			   
			0,			   
			1,			   
			v_descr_cia,   
			s_fecha_rep,
			m_reasegurador
	with resume;
end foreach
drop table tmp_xramo;
end
end procedure;	 