package cn.netease.liwu;
import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;




public class SendMail {


    public void sendMyMail(String host, String from, String[] to,
                           String subject, String content, String contentType, String[] attach,
                           boolean auth, String username, String password,String fake_from) throws Exception
    {
        Properties props = System.getProperties();
        //存储发送邮件服务器的信息, 使用smtp：简单邮件传输协议
        props.put("mail.smtp.host", host);
        if(!auth) props.put("mail.smtp.auth", "false");
        else props.put("mail.smtp.auth", "true");
        //根据属性新建一个邮件会话
        Session session = Session.getDefaultInstance(props, null);
        //由邮件会话新建一个消息对象
        MimeMessage message = new MimeMessage(session);
        //设置发件人的地址
        message.setFrom(new InternetAddress(from,fake_from));
        InternetAddress[] addrs = new InternetAddress[to.length];
        for(int i=0;i<to.length;i++) addrs[i] = new InternetAddress(to[i]);
        //设置收件人,并设置其接收类型为TO
        message.addRecipients(Message.RecipientType.TO, addrs);
        //设置标题
        message.setSubject(subject);
        //message.setContent(content, "text/html;charset=gb2312"); //发送HTML邮件
        //设置信件内容
        //if(contentType!=null && contentType.length()>0) message.setContent(content, contentType);
        //else message.setText(content); // send text/plain content ,发送纯文本

        //MiniMultipart类是一个容器类，包含MimeBodyPart类型的对象
        Multipart mainPart = new MimeMultipart();
        // 创建一个包含HTML内容的MimeBodyPart
        BodyPart html = new MimeBodyPart();
        // 设置HTML内容     建立第一部分： 文本正文
        if(contentType!=null && contentType.length()>0) html.setContent(content, contentType);
        else html.setText(content);
        mainPart.addBodyPart(html);
        // 将MiniMultipart对象设置为邮件内容   建立第二部分：附件
        message.setContent(mainPart);
        if(attach.length>0){
            for(int i=0;i<attach.length;i++){
                if (!attach[i].equals("")) {
                    // 建立第二部分：附件
                    html = new MimeBodyPart();
                    // 获得附件
                    DataSource source = new FileDataSource(attach[i]);
                    //设置附件的数据处理器
                    html.setDataHandler(new DataHandler(source));
                    // 设置附件文件名
                    String temp[] = attach[i].split("/"); /**split里面必须是正则表达式，"\\"的作用是对字符串转义*/
                    String fileName = temp[temp.length-1];
                    html.setFileName(fileName);
                    // 加入第二部分
                    mainPart.addBodyPart(html);
                }
            }
        }

        //发送邮件
        if (auth) {
            Transport smtp = null;
            try {
                smtp = session.getTransport("smtp");
                smtp.connect(host, username, password);
                smtp.sendMessage(message, message.getAllRecipients()); //发送邮件,其中第二个参数是所有已设好的收件人地址
            } catch (AddressException e) {
                e.printStackTrace();
            } catch (MessagingException e) {
                e.printStackTrace();
            } finally {
                smtp.close();
            }
        } else {
            Transport.send(message);
        }
    }






    public static void main(String[] args) {

        SendMail sm=new SendMail();
        String lang=args[5];
        String limit=args[6];
        String[] filename_array=args[2].split(",");
        ArrayList f=new ArrayList();
        for(int i=0;i<filename_array.length;i++) f.add(filename_array[i]);
        String host=args[3];
        String from=args[4];
        String[] to=args[0].split(",");
        String subject = args[1];
        String content = "";
        String contentType = "text/html;charset="+lang;
        String[] attach_array = new String[]{};
        if(!args[9].toString().equals("null")){
            attach_array=args[9].split(",");
        }
        boolean auth = true;
        String fake_from=args[4];
        String width=args[10];
        System.setProperty("mail.mime.charset",lang);
        String username = "";
        String password = "";
        auth=false;


        StringBuffer sb=new StringBuffer();
        String aLine="";
        sb.append("相关数据如下所示：");
        sb.append("<br>");
        sb.append("<br>");

        for(int j=0;j<f.size();j++){
            if(("").equals(f.get(j).toString())){
                break;
            }
            File file =new File(f.get(j).toString());
            sb.append("<table align=\"center\" border=\"0\" width=\""+width+"%\" cellspacing=\"1\" cellpadding=\"3\" bgcolor=\"#76CDD6\">");
            sb.append("<tr bgcolor=\"#FBFBFB\" align=\"center\">");

            HashMap hm=new HashMap();
            try {
                BufferedReader bf=new BufferedReader(new InputStreamReader(new FileInputStream(file),lang));
                int x=0;

                while((null!=(aLine=bf.readLine()))) {
                    if(x==0){
                        String[] a=aLine.split("\t",-1);
                        String temp = a[0];
                        Integer colspan = 1;
                        if(a.length==1){
                            sb.append("<td align=\"center\" colspan=\""+1+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                            sb.append("</tr>");
                        }else{
                            for(int i=1;i<a.length;i++){
                                if(i!=a.length-1){
                                    if(a[i].length()==0){
                                        colspan=colspan+1;
                                    }else{
                                        sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                                        temp=a[i];
                                        colspan=1;
                                    }
                                }else{
                                    if(a[i].length()==0){
                                        colspan=colspan+1;
                                        sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                                    }else{
                                        sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                                        sb.append("<td align=\"center\" colspan=\""+1+"\">"+"<font size=\"2\">"+a[i]+"</font>"+"</td>");
                                    }
                                    sb.append("</tr>");
                                }
                            }
                        }
                    }else{
                        hm.put(x, aLine);
                    }
                    x++;
                }
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            for(int y=1;y<=hm.size();y++){
                if(y>=Integer.parseInt(limit)){
                    break;
                }
                String[] a=hm.get(y).toString().split("\t",-1);
                Integer colspan = 1;
                String temp = a[0];
                if(y%2==0){
                    sb.append("<tr bgcolor=\"#FFFFFF\">");
                }else{
                    sb.append("<tr bgcolor=\"#DDDDDD\">");
                }

                if(a.length==1){
                    sb.append("<td align=\"center\" colspan=\""+1+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                    sb.append("</tr>");
                }else{
                    for(int i=1;i<a.length;i++){
                        if(i!=a.length-1){
                            if(a[i].length()==0){
                                colspan=colspan+1;
                            }else{
                                sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                                temp=a[i];
                                colspan=1;
                            }
                        }else{
                            if(a[i].length()==0){
                                colspan=colspan+1;
                                sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                            }else{
                                sb.append("<td align=\"center\" colspan=\""+colspan+"\">"+"<font size=\"2\">"+temp+"</font>"+"</td>");
                                sb.append("<td align=\"center\" colspan=\""+1+"\">"+"<font size=\"2\">"+a[i]+"</font>"+"</td>");
                            }
                            sb.append("</tr>");
                        }
                    }
                }

            }
            sb.append("</table>");
            sb.append("<br>");
            sb.append("<br>");
        }
        content = sb.toString();

        try {
            sm.sendMyMail(host, from, to, subject, content, contentType, attach_array, auth, username, password, fake_from);
        } catch(Exception e) {
            e.printStackTrace();
        }

    }
}
