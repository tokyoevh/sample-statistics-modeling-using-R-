library(MASS)
setwd("~/practical-stats-modeling/")

#�f�[�^��荞��
candidate_data<-read.csv("homework_data/bank_marketing_train.csv")

# #�w�K�f�[�^�ƃe�X�g�f�[�^�ɕ������Ă����܂��i���Ƃŗ\���̃f���̂��߁j
# train_idx<-sample(c(1:dim(candidate_data)[1]), size = dim(candidate_data)[1]*0.7)
# train<-candidate_data[train_idx, ]
# test<-candidate_data[-train_idx, ]


#�w�K�p(train_data)�ƃe�X�g�p(validation_data)�Ƀf�[�^�𕪂���
set.seed(1234)  # �R�[�h�̍Č�����ۂ���seed���Œ�
num_rows<-dim(candidate_data)[1]
num_rows
idx<-c(1:num_rows)
train_idx<-sample(idx, size = num_rows*0.7 )
train_data<-candidate_data[train_idx, ]
validation_data<-candidate_data[-train_idx, ]


#�f�[�^�m�F
head(candidate_data)
summary(candidate_data)
class(candidate_data$education)

#�S�̂̐��񗦂�7.4%
2747/(34321+2747)


#�Ƃ肠�����S�ϐ������Ă݂�
hr_data.lr<-glm(y~., data=train_data, family="binomial")
summary(hr_data.lr)

#���f���ϐ��i�^�[�Q�b�g�w�i�荞�݁j
#job(�E��)�F���ގ҂Ɗw�������� ���̐E��͑S��unknown�J�e�S���[��
#education(�w��)�F�w���������ƌ������₷��
#defaultunknown�i����������s���s���ĂȂ�(�A��unknown��s���s���Ă��Ȃ��Ɖ���)�j
#poutcomesuccess(�ߋ��̃L�����y�[���ō쐬���ЂƂ͌������₷���i�A������a��2�����邩�H���ӂ��K�v�j)
#���ɂ��}�N���o�ϗv���i�C���t���A�����A�i���j�͖����������������̂Ƃ���͖����A���n�񕪐́H�j

candidate_data$job[candidate_data$job=='housemaid']<-'unknown'
candidate_data$job[candidate_data$job=='blue-collar']<-'unknown'
candidate_data$job[candidate_data$job=='entrepreneur']<-'unknown'
candidate_data$job[candidate_data$job=='self-employed']<-'unknown'
candidate_data$job[candidate_data$job=='technician']<-'unknown'
candidate_data$job[candidate_data$job=='unemployed']<-'unknown'

#�J�^�_�ǉ� �ēx�A�w�K�p(train_data)�ƃe�X�g�p(validation_data)�Ƀf�[�^�𕪂���
set.seed(1234) # �R�[�h�̍Č�����ۂ���seed���Œ�
num_rows<-dim(candidate_data)[1]
num_rows
idx<-c(1:num_rows)
train_idx<-sample(idx, size = num_rows*0.7 )
train_data<-candidate_data[train_idx, ]
validation_data<-candidate_data[-train_idx, ]  



#��L�ϐ��ɂ��d��A���͎��{
c_data.lz<-glm(y~job+education+default+poutcome, data=train_data, family='binomial')
summary(c_data.lz)

#�I�b�Y�䌟�o�@
exp(c_data.lz$coefficients)

#prediction (Output)
mymodel<-glm(y~job+education+default+poutcome, data=train_data, family='binomial')
summary(mymodel)

#�쐬�������f�������ؗp�f�[�^�ɓK�p���A
#�}�[�P�e�B���O�L�����y�[���Ƀ��A�N�V��������m�������߂܂�
score<-predict(mymodel, validation_data, type = "response")

#�O��l�̌��؁F�N�b�N�̋���
ck_dist<-cooks.distance(c_data.lz)
4/length(ck_dist)
max(ck_dist,na.rm=TRUE)
plot(c_data.lz)

#�d�������m�FVIF
library(car)
car::vif(mymodel)

#�t���O���Ă�F�������1�Ȃ����͌������Ȃ�0
#0����1�܂ő������肵���ꍇ�̃t���O��ypred_flag�Ɋi�[��
#�ŏI�I�ɋ��߂����̂͂ǂ�x�i臒l�j��net_profit���ő剻���邩�����߂�B
#���c����R�[�h��������

precision<-NULL
roi<-NULL

for(i in 1:length(x)){
  ypred_flag<-ifelse(score > x[i], 1, 0)
  
  #confusion matrix���쐬
  conf_mat<-table(validation_data$y, ypred_flag )
  
  #score��臒l�ȏ�̐l = conf_mat[3]��con_mat[4]�̍��v�ɓd�b������
  attack_num<-conf_mat[3] + conf_mat[4]
  
  #�d�b�����邽�т�500�~������̂ŁA�R�X�g��your_cost�Ɋi�[
  your_cost <- attack_num * 500
  
  #����A�d�b�����Đ\������ł����l= conf_mat[4]�̐l����2000�~�����Ĕ�����v�Z
  expected_revenue<-conf_mat[4] * 2000
  
  #���ォ��R�X�g�������đe�� = ROI���v�Z
  tmp_roi<-expected_revenue - your_cost
  
  #�d�b���������l�̂����A�������銄�� = Precision���v�Z
  tmp_precision<-conf_mat[4]/attack_num
  
  #precision��append����
  precision<-c(precision, tmp_precision)
  
  #roi��append
  roi<-c(roi,tmp_roi)
}
# For�������܂�

conf_mat

plot(x, precision, type="l")
plot(x, roi, type="l")

#���オ�ő�ɂȂ�臒l��?
max(roi, na.rm = T)

#���オ�ő�ɂȂ�Ƃ���臒l�́H
x[which(roi==max(roi, na.rm = T))]

#threshold�ɎZ�o����臒l�����

threshold<-x[which(roi==max(roi, na.rm = T))]
threshold

my_func<-function(dataset){
  #�w�K�ς݂̃��f�����g���āAscore���v�Z
  score<-predict(mymodel, newdata = dataset, type="response")
  
  #���߂Ă���������臒l��flag�����Ă�
  ypred_flag<-ifelse(score > threshold, 1, 0)
  
  #�ǂ̐l�ɓd�b�����邩 �˓d���� = 1, ���Ȃ� = 0�@�ŏo��
  return(ypred_flag)
}

my_func(train_data)