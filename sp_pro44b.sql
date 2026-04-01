-- Procedimiento para la impresion de Notas del Facultativo
--
-- Creado    : 30/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 30/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 21/05/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

-- 21/05/2001 La Suma Asegurada y la Prima se obtiene de las Unidades
--            para las cuales un facultativo tiene movimientos (Demetrio)

DROP PROCEDURE sp_pro44b;
CREATE PROCEDURE sp_pro44b(a_poliza CHAR(10), a_endoso CHAR(5))
RETURNING   CHAR(3),			-- ls_coasegur
			CHAR(40),			-- ls_nom_coase
			CHAR(10),			-- ls_cod_cliente
			CHAR(100),			-- ls_nom_cli
			CHAR(20),			-- ls_no_documento
			DATE,				-- ldt_vini
			DATE,				-- ldt_vfin
			DECIMAL(16,2),		-- ld_suma_total
			DECIMAL(16,2),		-- ld_suma_rea
			DECIMAL(16,2),		-- ld_prima_total
			DECIMAL(16,2),		-- ld_prima_rea
			DECIMAL(16,2),		-- ld_comision
			DECIMAL(9,6),		-- ld_porc_comision
			DECIMAL(16,2),		-- ld_saldo
			CHAR(10),			-- ls_factura
			CHAR(10),			-- ls_no_cesion
			CHAR(60),			-- ls_fecha_letra
			CHAR(3),			-- ls_ramo
			CHAR(30),			-- ls_nom_ramo
			INTEGER,			-- li_tipo_ramo
			DECIMAL(16,2),		-- ld_porc_impuesto
			DECIMAL(16,2),		-- ld_impuesto
			char(35),
			CHAR(40);

DEFINE ls_cod_cober_reas    CHAR(3);
DEFINE ls_coasegur,ls_cod_perfac,ls_coasegur2 CHAR(3);
DEFINE ls_cod_cliente		CHAR(10);
DEFINE ls_nom_cli			CHAR(100);
DEFINE ls_nom_coase,ls_nom_coase2  CHAR(40);
DEFINE ls_no_documento		CHAR(20);
DEFINE ls_no_cesion			CHAR(10);
DEFINE ls_unidad			CHAR(10);
DEFINE ls_factura			CHAR(10);
DEFINE ls_fecha_letra		CHAR(60);
DEFINE ls_ramo				CHAR(3);
DEFINE ls_nom_ramo			CHAR(30);
DEFINE ls_no_unidad			CHAR(5);
DEFINE li_es_terremoto		SMALLINT;
DEFINE ldt_vini, ldt_vfin	DATE;
DEFINE ldt_fecha_emision	DATE;
DEFINE ld_suma_total		DEC(16,2);
DEFINE ld_prima_total		DEC(16,2);
DEFINE ld_suma_rea			DEC(16,2);
DEFINE ld_prima_rea			DEC(16,2);
DEFINE ld_comision			DEC(16,2);
DEFINE ld_impuesto			DEC(16,2);
DEFINE ld_impuesto2			DEC(16,2);
DEFINE ld_saldo				DEC(16,2);
DEFINE ld_porc_reas			DEC(16,4);
DEFINE ld_porc_comision		DEC(9,6);
DEFINE ld_porc_impuesto		DEC(16,4);
DEFINE ld_suma_temporal		DEC(16,2);
DEFINE ld_prima_temporal 	DEC(16,2);
DEFINE ld_monto_comision    DEC(16,2);
DEFINE ls_desc,ls_desc1     CHAR(35);
DEFINE li_tipo_ramo			INT;
DEFINE li_ramo_sis			INT;
define li_cant_garantia_pago,_tipo smallint;
define _cnt                 INT;

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro44b.trc";      
--TRACE ON;                                                                     
LET ls_desc = "";
LET ls_desc1 = "";
let ls_nom_coase2 = "";
let _tipo = 0;

let ld_suma_rea = 0.00;
Select endedmae.no_documento, 
       endedmae.vigencia_inic, 
       endedmae.vigencia_final,
	   endedmae.no_factura, 
	   endedmae.fecha_emision
  Into ls_no_documento, 
  	   ldt_vini, 
  	   ldt_vfin, 
       ls_factura, 
       ldt_fecha_emision
  From endedmae
 Where endedmae.no_poliza = a_poliza
   And endedmae.no_endoso = a_endoso;

Select emipomae.cod_ramo
  Into ls_ramo
  From emipomae
 Where no_poliza = a_poliza;

Select prdramo.nombre, prdtiram.tipo_ramo, prdramo.ramo_sis
  Into ls_nom_ramo, li_tipo_ramo, li_ramo_sis
  From prdramo, prdtiram
 Where prdramo.cod_ramo = ls_ramo
   And prdtiram.cod_tiporamo = prdramo.cod_tiporamo;

{
	SELECT X.cod_coasegur, X.porc_partic_reas, X.porc_comis_fac,
		   X.porc_impuesto
    	   sum(X.suma_asegurada), Sum(X.prima), Sum(X.no_cesion), Sum(X.no_unidad)
	  INTO ls_coasegur, ld_porc_reas, ld_porc_comision, ld_porc_impuesto
	       ld_suma_rea, ld_prima_rea, ls_no_cesion, ls_unidad
      FROM emifafac X
     WHERE X.no_poliza = a_poliza
       AND X.no_endoso = a_endoso
	GROUP BY X.cod_coasegur, X.cod_coasegur, X.porc_partic_reas, X.porc_comis_fac
    ORDER BY X.cod_coasegur
}

let ls_cod_perfac = null;
let ls_coasegur2 = null;
let li_cant_garantia_pago = 0;
FOREACH
	SELECT emifafac.cod_coasegur, 
		   emifafac.porc_partic_reas, 
	       emifafac.porc_comis_fac, 
	       emifafac.porc_impuesto, 
	       emifafac.no_cesion,
           (emifafac.porc_comis_fac * Sum(emifafac.prima)/100),
		   (emifafac.porc_impuesto * Sum(emifafac.prima)/100),
		   SUM(emifafac.prima),
		   SUM(emifafac.monto_comision),
		   SUM(emifafac.monto_impuesto),
		   emifafac.cod_perfac,
		   emifafac.cant_garantia_pago,
		   emifafac.cod_coasegur2
	  INTO ls_coasegur, 
	  	   ld_porc_reas, 
	  	   ld_porc_comision, 
	       ld_porc_impuesto, 
	       ls_no_cesion,
	       ld_comision, 
	       ld_impuesto, 
	       ld_prima_rea,
		   ld_monto_comision,
		   ld_impuesto2,
		   ls_cod_perfac,
		   li_cant_garantia_pago,
		   ls_coasegur2
      FROM emifafac emifafac
     WHERE emifafac.no_poliza = a_poliza
       AND emifafac.no_endoso = a_endoso
	 GROUP BY emifafac.cod_coasegur, emifafac.porc_partic_reas, 
	          emifafac.porc_comis_fac, emifafac.porc_impuesto, emifafac.no_cesion,emifafac.cod_perfac,emifafac.cant_garantia_pago,emifafac.cod_coasegur2
     ORDER BY emifafac.cod_coasegur

	{if ls_coasegur2 is not null and trim(ls_coasegur2) <> "" then
		let ls_coasegur = ls_coasegur2;
    end if}
	let ls_nom_coase2 = "";
	let ls_nom_coase      = "";
	if ls_cod_perfac is null then
		let ls_cod_perfac = '';
	end if
	
	if li_cant_garantia_pago is null then
		let li_cant_garantia_pago = 0;
	end if

	if ls_cod_perfac = '' then
		let ls_desc1 = '';
	else
		select descripcion 
		  into ls_desc 
		 from reaperfac
		where cod_perfac = ls_cod_perfac;

		let ls_desc1 = 'GARANTIA DE PAGO: ' || li_cant_garantia_pago || " " || ls_desc;
	end if	

 {	SELECT emifafac.cod_coasegur, 
		   emifafac.porc_partic_reas, 
	       emifafac.porc_comis_fac, 
	       emifafac.porc_impuesto, 
	       emifafac.no_cesion,
		   SUM(emifafac.monto_comision),
		   SUM(emifafac.prima),
		   SUM(emifafac.monto_impuesto)
	  INTO ls_coasegur, 
	  	   ld_porc_reas, 
	  	   ld_porc_comision, 
	       ld_porc_impuesto, 
	       ls_no_cesion,
	       ld_comision, 
	       ld_prima_rea,
	       ld_impuesto
      FROM emifafac emifafac
     WHERE emifafac.no_poliza = a_poliza
       AND emifafac.no_endoso = a_endoso
	 GROUP BY emifafac.cod_coasegur, emifafac.porc_partic_reas, 
	          emifafac.porc_comis_fac, emifafac.porc_impuesto, emifafac.no_cesion
     ORDER BY emifafac.cod_coasegur	}


    LET ld_suma_total  = 0;
    LET ld_prima_total = 0;

    FOREACH
	SELECT emifafac.no_unidad
	  INTO ls_no_unidad 
      FROM emifafac emifafac
     WHERE emifafac.no_poliza    = a_poliza
       AND emifafac.no_endoso    = a_endoso
	   AND emifafac.cod_coasegur = ls_coasegur
	 GROUP BY emifafac.no_unidad
		
		SELECT suma_asegurada,
		       prima_suscrita
		  INTO ld_suma_temporal,
		       ld_prima_temporal
		  FROM endeduni
	     WHERE no_poliza = a_poliza
    	   AND no_endoso = a_endoso
	   	   AND no_unidad = ls_no_unidad;

		LET ld_suma_total  = ld_suma_total  + ld_suma_temporal;
		LET ld_prima_total = ld_prima_total + ld_prima_temporal;

	END FOREACH
	if ls_ramo in('002','023') then
		foreach
			SELECT SUM(emifafac.suma_asegurada),emifafac.cod_cober_reas
			  INTO ld_suma_rea,ls_cod_cober_reas
			  FROM emifafac emifafac, reacobre reacobre
			 WHERE emifafac.no_poliza      = a_poliza
			   AND emifafac.no_endoso      = a_endoso
			   AND emifafac.cod_coasegur   = ls_coasegur
			   AND reacobre.cod_cober_reas = emifafac.cod_cober_reas
			   AND reacobre.es_terremoto   <> 1
			 group by emifafac.cod_cober_reas
			exit foreach;
		end foreach
	else
		foreach
			SELECT SUM(emifafac.suma_asegurada), emifafac.cod_cober_reas
			  INTO ld_suma_rea,ls_cod_cober_reas
			  FROM emifafac emifafac, reacobre reacobre
			 WHERE emifafac.no_poliza      = a_poliza
			   AND emifafac.no_endoso      = a_endoso
			   AND emifafac.cod_coasegur   = ls_coasegur
			   AND reacobre.cod_cober_reas = emifafac.cod_cober_reas
			   AND reacobre.es_terremoto   <> 1
			   group by emifafac.cod_cober_reas

			exit foreach;
		end foreach
	end if

	If ld_comision Is Null Then
	   Let ld_comision = 0.00;
	End If
	
	If ld_impuesto Is Null Then
	   Let ld_impuesto = 0.00;
	End If

	if ld_prima_rea = 0 then
		LET ld_saldo = ld_prima_rea - ld_monto_comision - ld_impuesto2;
	else
		LET ld_saldo = ld_prima_rea - ld_comision - ld_impuesto;
	end if

    let ls_ramo = ls_ramo;

	if ls_ramo = "016" or ls_ramo = "018" then

		Select cod_contratante
		  Into ls_cod_cliente
		  From emipomae
		 Where no_poliza = a_poliza;

		select nombre
		  into ls_nom_cli
		  from cliclien
		 where cod_cliente = ls_cod_cliente;

	else
	    select count(*)
		  into _cnt
		  from endeduni
		 where endeduni.no_poliza 	= a_poliza
		   AND endeduni.no_endoso 	= a_endoso;
		   
        if _cnt > 0 then
			Select cod_contratante
			  Into ls_cod_cliente
			  From emipomae
			 Where no_poliza = a_poliza;

			select nombre
			  into ls_nom_cli
			  from cliclien
			 where cod_cliente = ls_cod_cliente;
		else
			SELECT Unique endeduni.cod_cliente, cliclien.nombre
			  INTO ls_cod_cliente, ls_nom_cli
			  FROM cliclien, endeduni
			 WHERE endeduni.no_poliza 	= a_poliza
			   AND endeduni.no_endoso 	= a_endoso
			   AND cliclien.cod_cliente = endeduni.cod_cliente;
        end if
		
        let  ls_cod_cliente = ls_cod_cliente;
		let  ls_nom_cli = ls_nom_cli;

	end if

	Select nombre,
	       tipo
	  Into ls_nom_coase,
	       _tipo
	  From emicoase
	 Where cod_coasegur = ls_coasegur;
	
	if _tipo = 0 then	--Es Reaseguradora
		if ls_coasegur2 <> "" or ls_coasegur2 is not null then
			{Select nombre
			  Into ls_nom_coase2
			  From emicoase
			 Where cod_coasegur = ls_coasegur2;}
			 let ls_nom_coase2 = "";

		end if
	else				--Es Corredor de reaseguro
		let ls_nom_coase2 = ls_nom_coase;	--Se coloca en varieble que mostrara el nombre del correodor de reaseguro
		{if ls_coasegur2 <> "" or ls_coasegur2 is not null then
			Select nombre
			  Into ls_nom_coase
			  From emicoase
			 Where cod_coasegur = ls_coasegur2;

		end if}
		if _tipo = 1 then	
			let ls_nom_coase = "";
			let ls_nom_coase2 = "";
			Select nombre
			  Into ls_nom_coase2
			  From emicoase
			 Where cod_coasegur = ls_coasegur;			 			
		else
			--let ls_nom_coase = "";
			--let ls_nom_coase2 = ls_nom_coase;
			Select nombre
			  Into ls_nom_coase2
			  From emicoase
			 Where cod_coasegur = ls_coasegur2;		
			 
				If ls_nom_coase2 IS NULL Then
				   LET ls_nom_coase2 = "";
				End If			 
		end if
	end if

	If ldt_fecha_emision IS NULL Then
	   LET ldt_fecha_emision = Today;
	End If

	Call sp_sis20(ldt_fecha_emision) RETURNING ls_fecha_letra;

    If li_ramo_sis = 2 Then
--	   LET ld_suma_rea = ld_suma_rea / 2;
    End If

{
	Select es_terremoto INTO li_es_terremoto
	  From reacobre
	 Where cod_cober_reas = ls_cod_cober_reas;

    IF li_es_terremoto = 1 Then
	   LET ld_suma_rea = 0.00;
    END IF

	LET ld_tot_suma_rea = ld_tot_suma_rea + ld_suma_rea;

}
{    If ld_comision = 0.00 Then
	   let ld_comision = ld_monto_comision;
	End If}
	RETURN ls_coasegur, 
		   ls_nom_coase, 
		   ls_cod_cliente, 
		   ls_nom_cli, 
		   ls_no_documento, 
		   ldt_vini, 
		   ldt_vfin,
	       ld_suma_total, 
	       ld_suma_rea, 
	       ld_prima_total, 
	       ld_prima_rea,
		   ld_monto_comision, 
		   ld_porc_comision, 
		   ld_saldo, 
		   ls_factura,
		   ls_no_cesion, 
		   ls_fecha_letra, 
		   ls_ramo, 
		   ls_nom_ramo, 
		   li_tipo_ramo, 
		   ld_porc_impuesto, 
		   ld_impuesto2,
		   ls_desc1,
		   ls_nom_coase2
		   WITH RESUME;

END FOREACH

END

END PROCEDURE;